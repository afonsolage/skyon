using CommonLib.Messaging.Client;
using CommonLib.Messaging.Common;
using CommonLib.Networking;
using CommonLib.Server;
using CommonLib.Util;
using CommonLib.Util.Math;
using MapServer.Logic.Object;
using MapServer.Server;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MapServer.Logic.Map
{
    public class MapInstanceID : IComparable<MapInstanceID>
    {
        public Vec2 position;
        public ushort channel;

        public int CompareTo(MapInstanceID other)
        {
            if (other.position == position)
            {
                return channel.CompareTo(other.channel);
            }
            else
            {
                return position.CompareTo(other.position);
            }
        }

        public override bool Equals(object obj)
        {
            return obj is MapInstanceID iD &&
                   position == iD.position &&
                   channel == iD.channel;
        }

        public override int GetHashCode()
        {
            return GMath.ComputeHash(position.GetHashCode(), channel);
        }

        public override string ToString()
        {
            return string.Format("({0},{1})[{2}]", position.x, position.y, channel);
        }
    }

    struct MapInstanceMessage
    {
        public ClientSession session;
        public RawMessage message;
    }

    class MapInstance : ITickable
    {
        private const int MAP_INSTANCE_TPS = 30;

        private readonly MapInstanceID _id;
        private readonly ConcurrentQueue<MapInstanceMessage> _processingQueue;
        private readonly Dictionary<uint, Player> _players;

        public AppServer App { get; private set; }
        public TileMap Map { get; set; }


        public MapInstance(AppServer app, MapInstanceID id)
        {
            App = app;
            _id = id;
            _players = new Dictionary<uint, Player>();
            _processingQueue = new ConcurrentQueue<MapInstanceMessage>();
        }

        public string Name => $"Map Instance {_id}";

        public void Dispose()
        {
            App.Unregister(this);
        }

        public void Post(ClientSession session, RawMessage message)
        {
            _processingQueue.Enqueue(new MapInstanceMessage()
            {
                session = session,
                message = message,
            });
        }

        public void Tick(float delta)
        {
            ProcessMessages();
        }

        private void ProcessMessages()
        {
            while (_processingQueue.TryDequeue(out var msg))
            {
                if (!msg.session.Connected)
                {
                    Leave(msg.session);
                    continue;
                }
                switch (msg.message.MsgType)
                {
                    case MessageType.CM_REQ_JOIN_MAP:
                        Join(msg.session, msg.message.To<CM_REQ_JOIN_MAP>());
                        break;
                    default:
                        CLog.W("Unrecognized map instance message type: {0}.", msg.message.MsgType);
                        break;
                }
            }
        }

        private void Leave(ClientSession session)
        {
            _players.Remove(session.ID);
        }

        internal void Start()
        {
            App.Register(this, MAP_INSTANCE_TPS);
        }

        private void Join(ClientSession session, CM_REQ_JOIN_MAP req)
        {
            var player = new Player(session);
            _players[session.ID] = player;

            var res = new MC_RES_JOIN_MAP()
            {
                tileMap = new TileMapSimple()
                {
                    tileType = CompressionHelper.Compress(Map.TileType.Cast<byte>().ToArray()),
                }
            };

            player.Session.Send(res); ;
        }
    }
}

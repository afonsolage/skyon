using CommonLib.Logic.Map;
using CommonLib.Messaging.Common;
using CommonLib.Messaging.Server;
using CommonLib.Networking;
using CommonLib.Util;
using CommonLib.Util.Math;
using MapServer.Logic.Map;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MapServer.Server
{
    class MapInstanceManager
    {
        private readonly AppServer _app;
        private readonly ConcurrentDictionary<MapInstanceID, MapInstance> _mapInstanceDict;
        public MapInstanceManager(AppServer app)
        {
            _app = app;
            _mapInstanceDict = new ConcurrentDictionary<MapInstanceID, MapInstance>();
        }

        internal MapInstance GetMapInstance(int x, int y, int channel)
        {
            var id = new MapInstanceID()
            {
                position = new Vec2(x, y),
                channel = (ushort)channel,
            };

            if (!_mapInstanceDict.TryGetValue(id, out var result))
                return null;
            else
                return result;
        }

        public void LoadMap(int x, int y, int channel)
        {
            var id = new MapInstanceID()
            {
                position = new Vec2(x, y),
                channel = (ushort)channel,
            };

            if (_mapInstanceDict.ContainsKey(id))
                return;

            var mapInstance = new MapInstance(_app, id);

            if (!_mapInstanceDict.TryAdd(id, mapInstance))
                return;

            _app.DBClient.Send(new MD_REQ_MAP_INFO()
            {
                x = id.position.x,
                y = id.position.y,
                channel = id.channel,
            });
        }

        public void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);

            switch (rawMessage.MsgType)
            {
                case MessageType.DM_RES_MAP_INFO:
                    {
                        SetMapInfo(rawMessage.To<DM_RES_MAP_INFO>());
                    }
                    break;
                default:
                    CLog.W("Unrecognized client message type: {0}.", rawMessage.MsgType);
                    break;
            }
        }

        private void SetMapInfo(DM_RES_MAP_INFO res)
        {
            var id = new MapInstanceID()
            {
                position = new Vec2(res.tileMap.x, res.tileMap.y),
                channel = res.channel,
            };

            if (!_mapInstanceDict.TryGetValue(id, out var instance))
            {
                CLog.E("Failed to get map {0}", id);
                return;
            }
            var heightMap = CompressionHelper.Decompress(res.tileMap.heightMap);
            var tilesType = CompressionHelper.Decompress(res.tileMap.tileType).Cast<TileType>().ToArray();

            instance.Map = new TileMap(id.position, heightMap, tilesType);
            instance.Start();
        }

        public bool IsMapLoaded(int x, int y, int channel)
        {
            var id = new MapInstanceID()
            {
                position = new Vec2(x, y),
                channel = (ushort)channel,
            };

            return _mapInstanceDict.ContainsKey(id);
        }
    }
}

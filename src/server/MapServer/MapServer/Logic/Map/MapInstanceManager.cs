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
                case MessageType.PM_RES_MAP_GEN:
                    {
                        var res = rawMessage.To<PM_RES_MAP_GEN>();
                        CLog.I("Map {0},{1} generated. Loading", res.x, res.y);
                        _app.DBClient.Send(new MD_REQ_MAP_INFO()
                        {
                            x = res.x,
                            y = res.y,
                            channel = res.channel,
                        });
                    }
                    break;
                default:
                    CLog.W("Unrecognized client message type: {0}.", rawMessage.MsgType);
                    break;
            }
        }

        private void SetMapInfo(DM_RES_MAP_INFO res)
        {
            if (res.tileMap.heightMap == null)
            {
                CLog.I("Map {0},{1} doesn't exists. Asking Procedural Server for a new one", res.tileMap.x, res.tileMap.y);
                RequestMapGeneration(res.tileMap.x, res.tileMap.y, res.channel);
                return;
            }

            var id = new MapInstanceID()
            {
                position = new Vec2(res.tileMap.x, res.tileMap.y),
                channel = (ushort)res.channel,
            };

            if (!_mapInstanceDict.TryGetValue(id, out var instance))
            {
                CLog.I("Failed to get map {0}", id);
                return;
            }

            var heightMap = CompressionHelper.Decompress(res.tileMap.heightMap);
            var tilesType = CompressionHelper.Decompress(res.tileMap.tileType).Cast<TileType>().ToArray();

            instance.Map = new TileMap(id.position, heightMap, tilesType);
            instance.Start();

            CLog.I("Map {0},{1}[{2}] loaded!", res.tileMap.x, res.tileMap.y, res.channel);
        }

        private void RequestMapGeneration(int x, int y, int channel)
        {
            _app.PCClient.Send(new MP_REQ_MAP_GEN()
            {
                x = x,
                y = y,
                channel = channel,
            });
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

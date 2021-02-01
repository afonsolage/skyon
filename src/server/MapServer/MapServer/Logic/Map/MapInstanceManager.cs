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
        private readonly ConcurrentDictionary<Vec2, TileMap> _maps;

        public MapInstanceManager(AppServer app)
        {
            _app = app;
            _mapInstanceDict = new ConcurrentDictionary<MapInstanceID, MapInstance>();
            _maps = new ConcurrentDictionary<Vec2, TileMap>();
        }

        internal MapInstance GetMapInstance(int x, int y, int channel)
        {
            var id = new MapInstanceID()
            {
                position = new Vec2(x, y),
                channel = (ushort)channel,
            };

            if (_mapInstanceDict.TryGetValue(id, out var result))
            {
                return result;
            }
            else
            {
                return TryCreateMapInstance(id);
            }
        }

        private MapInstance TryCreateMapInstance(MapInstanceID id)
        {
            if (_maps.TryGetValue(id.position, out var tileMap))
            {
                var mapInstance = new MapInstance(_app, id)
                {
                    Map = tileMap,
                };

                mapInstance.Start();

                if (!_mapInstanceDict.TryAdd(id, mapInstance))
                {
                    CLog.E("Failed to create map instance {0},{1}. Unable to add to map dict.", id.position.x, id.position.y);
                    return null;
                }

                return mapInstance;
            }
            else
            {
                return null;
            }
        }

        public void LoadMap(int x, int y)
        {
            if (_maps.ContainsKey(new Vec2(x, y)))
            {
                CLog.W("Map was already loaded: {0},{1}", x, y);
                return;
            }

            _app.DBClient.Send(new MD_REQ_MAP_INFO()
            {
                x = x,
                y = y,
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
                RequestMapGeneration(res.tileMap.x, res.tileMap.y);
                return;
            }

            var heightMap = CompressionHelper.Decompress(res.tileMap.heightMap);
            var tilesType = CompressionHelper.Decompress(res.tileMap.tileType).Cast<TileType>().ToArray();

            var tileMap = new TileMap(new Vec2(res.tileMap.x, res.tileMap.y), heightMap, tilesType);

            if (!_maps.TryAdd(tileMap.Position, tileMap))
            {
                CLog.E("Failed to add Map {0},{1}!", res.tileMap.x, res.tileMap.y);
            }
            else
            {
                CLog.I("Map {0},{1} loaded!", res.tileMap.x, res.tileMap.y);
            }
        }

        private void RequestMapGeneration(int x, int y)
        {
            _app.PCClient.Send(new MP_REQ_MAP_GEN()
            {
                x = x,
                y = y,
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

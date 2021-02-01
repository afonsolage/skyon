using CommonLib.Messaging.Server;
using CommonLib.Util;
using CommonLib.Util.Math;
using ProceduralServer.Server;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text;

namespace ProceduralServer.Logic.Map
{
    static class MapHandler
    {
        private static ConcurrentDictionary<Vec2, ConcurrentQueue<ClientSession>> _pendingMapsSessions = new ConcurrentDictionary<Vec2, ConcurrentQueue<ClientSession>>();

        internal static void ReqMapGen(MP_REQ_MAP_GEN req, ClientSession session)
        {
            session.App.DBClient.Send(new PD_REQ_SURROUNDING_CONNECTIONS()
            {
                x = req.x,
                y = req.y,
            });

            var queue = _pendingMapsSessions.GetOrAdd(new Vec2(req.x, req.y), new ConcurrentQueue<ClientSession>());
            queue.Enqueue(session);
        }

        internal static void ResSurroundingConnections(DP_RES_SURROUNDING_CONNECTIONS res, DatabaseClient dbSession)
        {
            //TODO: Find a better place for this
            var settings = new TileMapSettings
            {
                size = 1024,
                position = new Vec2(res.x, res.y),
                frequency = 2,
                fractalOctaves = 2,
                fractalLacunarity = 2,
                fractalGain = 2,

                borderSize = (int)(1024 * 0.05f),
                borderThickness = 0.05f,
                borderMontains = true,

                borderConnectionSize = (int)(1024 * 0.05f),
                hasSurroundingConnections = new bool[] {res.has_top_connection, res.has_right_connection, res.has_down_connection, res.has_left_connection},
                surroundingConnections = new Vec2[] {res.top_connection, res.right_connection, res.down_connection, res.left_connection},
            };

            var tileMap = MapGenerator.Generate(settings);
            var upsert = new PD_NFY_UPSERT_MAP()
            {
                tileMap = new TileMapData()
                {
                    x = res.x,
                    y = res.y,
                    heightMap = CompressionHelper.Compress(tileMap.HeightBuffer),
                    tileType = CompressionHelper.Compress(tileMap.TileBuffer),
                    topConnection = tileMap.Connections[0],
                    rightConnection = tileMap.Connections[1],
                    downConnection = tileMap.Connections[2],
                    leftConnection = tileMap.Connections[3]
                }
            };
            dbSession.Send(upsert);

            if (_pendingMapsSessions.TryGetValue(new Vec2(res.x, res.y), out var queue))
            {
                while(queue.TryDequeue(out var session))
                {
                    session.Send(new PM_RES_MAP_GEN()
                    {
                        x = res.x,
                        y = res.y,
                    });
                }
            }
        }
    }
}

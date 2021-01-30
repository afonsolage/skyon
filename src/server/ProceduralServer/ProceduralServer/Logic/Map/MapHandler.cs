using CommonLib.Messaging.Server;
using CommonLib.Util;
using CommonLib.Util.Math;
using ProceduralServer.Server;
using System;
using System.Collections.Generic;
using System.Text;

namespace ProceduralServer.Logic.Map
{
    static class MapHandler
    {
        internal static void ReqMapGen(MP_REQ_MAP_GEN req, ClientSession session)
        {
            //TODO: Find a better place for this
            var settings = new TileMapSettings
            {
                size = 1024,
                position = new Vec2(req.x, req.y),
                frequency = 2,
                fractalOctaves = 2,
                fractalLacunarity = 2,
                fractalGain = 2,

                borderSize = (int)(1024 * 0.05f),
                borderThickness = 0.05f,
                borderMontains = true,

                borderConnectionSize = (int)(1024 * 0.05f),
            };

            var tileMap = MapGenerator.Generate(settings);
            var upsert = new PD_NFY_UPSERT_MAP()
            {
                tileMap = new TileMapData()
                {
                    x = req.x,
                    y = req.y,
                    heightMap = CompressionHelper.Compress(tileMap.HeightBuffer),
                    tileType = CompressionHelper.Compress(tileMap.TileBuffer),
                }
            };
            session.App.DBClient.Send(upsert);
            session.Send(new PM_RES_MAP_GEN()
            {
                x = req.x,
                y = req.y,
                channel = req.channel,
            });
        }
    }
}

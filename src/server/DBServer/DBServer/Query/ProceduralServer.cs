using CommonLib.DB;
using CommonLib.Messaging.Server;
using DBServer.Server;
using System;
using System.Collections.Generic;
using System.Text;

namespace DBServer.Query
{
    public static class ProceduralServer
    {
        private const string CONNECTION_NAME = "general";

        internal static void NfyUpsertMap(PD_NFY_UPSERT_MAP req, ClientSession session)
        {
            using (var conn = new DBConnection(CONNECTION_NAME))
            {
                conn.Execute("INSERT INTO tile_map (x, y, height_map, tile_type) VALUES (@p1, @p2, @p3, @p4) ON CONFLICT(x, y) DO UPDATE SET height_map = @p3, tile_type = @p4",
                    req.tileMap.x,
                    req.tileMap.y,
                    req.tileMap.heightMap,
                    req.tileMap.tileType);
            }
        }
    }
}

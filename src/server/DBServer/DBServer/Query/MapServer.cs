using CommonLib.DB;
using CommonLib.Messaging.Server;
using DBServer.Server;
using System;
using System.Collections.Generic;
using System.Text;

namespace DBServer.Query
{
    public static class MapServer
    {
        private const string CONNECTION_NAME = "general";

        internal static void NfyUpsertMap(MD_REQ_MAP_INFO req, ClientSession session)
        {
            using (var conn = new DBConnection(CONNECTION_NAME))
            {
                var resultSet = conn.Query("SELECT height_map, tile_type FROM tile_map WHERE x = @p1 and y = @p2", req.x, req.y);

                var res = new DM_RES_MAP_INFO();
                res.tileMap.x = req.x;
                res.tileMap.y = req.y;
                res.tileMap.heightMap = resultSet.GetByteArray(0);
                res.tileMap.heightMap = resultSet.GetByteArray(1);

                session.Send(res);
            }
        }
    }
}

using CommonLib.DB;
using CommonLib.Messaging.Server;
using CommonLib.Util;
using CommonLib.Util.Math;
using DBServer.Server;
using System;
using System.Collections.Generic;
using System.Linq;
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
                conn.Execute(@"
                    INSERT INTO tile_map (x, y, height_map, tile_type, 
                    top_connection_x, top_connection_y, right_connection_x, right_connection_y, down_connection_x, down_connection_y, left_connection_x, left_connection_y) 
                    VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12)
                    ON CONFLICT(x, y) DO UPDATE SET height_map = @p3, tile_type = @p4, 
                        top_connection_x = @p5, top_connection_y = @p6, right_connection_x = @p7, right_connection_y = @p8, down_connection_x = @p9, down_connection_y = @p10, left_connection_x = @p11, left_connection_y = @p12",
                    req.tileMap.x,
                    req.tileMap.y,
                    req.tileMap.heightMap,
                    req.tileMap.tileType,
                    req.tileMap.topConnection.x,
                    req.tileMap.topConnection.y,
                    req.tileMap.rightConnection.x,
                    req.tileMap.rightConnection.y,
                    req.tileMap.downConnection.x,
                    req.tileMap.downConnection.y,
                    req.tileMap.leftConnection.x,
                    req.tileMap.leftConnection.y);
            }
        }

        internal static void ReqSurroundingConnections(PD_REQ_SURROUNDING_CONNECTIONS req, ClientSession session)
        {
            using (var conn = new DBConnection(CONNECTION_NAME))
            {
                var surroundings = new Vec2[Vec2.ALL_DIRS.Length];
                var opositeDirections = Vec2.ALL_DIRS.Select(v => v * -1).ToArray();

                var query = @"SELECT down_connection_x as x, down_connection_y as y, 'down' as side FROM tile_map WHERE x = @p1 AND y = @p2
                            UNION
                            SELECT top_connection_x as x, top_connection_y as y, 'top' as side FROM tile_map WHERE x = @p3 AND y = @p4
                            UNION
                            SELECT left_connection_x as x, left_connection_y as y, 'left' as side FROM tile_map WHERE x = @p5 AND y = @p6
                            UNION
                            SELECT right_connection_x as x, right_connection_y as y, 'right' as side FROM tile_map WHERE x = @p7 AND y = @p8";

                var resultSet = conn.Query(query,
                    req.x, req.y + 1, //Top map
                    req.x, req.y - 1, //Down map
                    req.x + 1, req.y, //Right map
                    req.x - 1, req.y //Left map
                    );


                var res = new DP_RES_SURROUNDING_CONNECTIONS()
                {
                    x = req.x,
                    y = req.y,
                    down_connection = Vec2.INVALID,
                    top_connection = Vec2.INVALID,
                    left_connection = Vec2.INVALID,
                    right_connection = Vec2.INVALID,
                    has_top_connection = false,
                    has_right_connection = false,
                    has_down_connection = false,
                    has_left_connection = false,
                };

                while (resultSet.Read())
                {
                    var x = resultSet.GetInt16(0);
                    var y = resultSet.GetInt16(1);
                    var side = resultSet.GetString(2);

                    switch (side)
                    {
                        case "down":
                            res.top_connection = new Vec2(x, y);
                            res.has_top_connection = true;
                            break;
                        case "top":
                            res.down_connection = new Vec2(x, y);
                            res.has_down_connection = true;
                            break;
                        case "left":
                            res.right_connection = new Vec2(x, y);
                            res.has_right_connection = true;
                            break;
                        case "right":
                            res.left_connection = new Vec2(x, y);
                            res.has_left_connection = true;
                            break;
                        default:
                            CLog.E("Invalid side ({0}) returned on query surroundings of map {1}, {2}", side, req.x, req.y);
                            break;
                    }
                }

                session.Send(res);
            }
        }
    }
}

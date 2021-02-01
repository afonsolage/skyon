#if _SERVER
using CommonLib.Util.Math;
using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Messaging.Server
{
    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class TileMapData
    {
        public int x;
        public int y;
        public byte[] heightMap;
        public byte[] tileType;
        public Vec2 topConnection;
        public Vec2 rightConnection;
        public Vec2 downConnection;
        public Vec2 leftConnection;
    }
}

#endif
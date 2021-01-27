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
    public class TileMap
    {
        public int x;
        public int y;
        public byte[] heightMap;
        public byte[] tileType;
    }
}

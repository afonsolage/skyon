using CommonLib.Logic.Map;
using CommonLib.Util.Math;

namespace MapServer.Logic.Map
{
    class TileMap
    {
        public Vec2 Position { get;}

        public byte[] HeightMap { get; private set; }
        public TileType[] TileType { get; private set; }

        public TileMap(Vec2 position, byte[] heightMap, TileType[] tyleType)
        {
            Position = position;
            HeightMap = heightMap;
            TileType = tyleType;
        }

        public override string ToString()
        {
            return $"Tile Map ({Position.x}, {Position.y})";
        }
    }
}

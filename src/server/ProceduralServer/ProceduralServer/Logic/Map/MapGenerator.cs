using CommonLib.Util.Math;
using System;
using System.Collections.Generic;

namespace ProceduralServer.Logic.Map
{
    enum TileType
    {
        Grass,
        Rock,
        Sand,
        Dirt,
        Snow,
        DeepWater,
        Water,
    }

    struct TileMapSettings
    {
        public int size;

        public Vec2 position;
        public float frequency; //This is the "zoom" of the noise. Numbers should be between 0,001 and 0,030

        public int fractalOctaves; //Number of loops of the fractal. The higher the number, more "grain" it'll be
        public float fractalLacunarity; //This is like the "Zoom". The higher the number, more noise (like a terrain with spike montains). Values can be 
        public float fractalGain; //This is the "transparency" of the fractal applied above the noise. Values can be between 0.0 and 10.0

        public int borderSize;
        public float borderThickness;
        public bool borderMontains;

        public int borderConnectionSize;
    }

    class TileMap
    {
        public TileMap(int size)
        {
            _size = size;
            _tileType = new byte[size * size];
            _heightMap = new float[size * size];
        }

        private readonly int _size;
        public int Size
        {
            get => _size;
        }

        private float[] _heightMap;
        private byte[] _tileType;

        public float[] HeightBuffer { get => _heightMap; }

        public void SetHeight(int x, int y, float height)
        {
            _heightMap[x + y * _size] = height;
        }

        public float GetHeight(int x, int y)
        {
            return _heightMap[x + y * _size];
        }

        public void SetHeight(Vec2 pos, float height)
        {
            _heightMap[pos.x + pos.y * _size] = height;
        }

        public float GetHeight(Vec2 pos)
        {
            return _heightMap[pos.x + pos.y * _size];
        }

        public int ToIndex(Vec2i pos)
        {
            return pos.x + pos.y * _size;
        }

        public TileType this[int i]
        {
            get { return (TileType)_tileType[i]; }
            set { _tileType[i] = (byte)value; }
        }

        public TileType this[int x, int y]
        {
            get { return (TileType)_tileType[x + y * _size]; }
            set { _tileType[x + y * _size] = (byte)value; }
        }

        public TileType this[Vec2 pos]
        {
            get { return (TileType)_tileType[pos.x + pos.y * _size]; }
            set { _tileType[pos.x + pos.y * _size] = (byte)value; }
        }
    }


    class MapGenerator
    {
        public static TileMap Generate(TileMapSettings settings)
        {
            var tileMap = new TileMap(settings.size);

            GenerateHeightMap(settings, tileMap);
            GenerateBorder(settings, tileMap);
            GenerateConnections(settings, tileMap);

            ComputeTileType(settings, tileMap);

            return tileMap;
        }

        private static void ComputeTileType(TileMapSettings settings, TileMap tileMap)
        {
            for (var x = 0; x < settings.size; x++)
            {
                for (var y = 0; y < settings.size; y++)
                {
                    //TODO: Find a better place to se this

                    var h = tileMap.GetHeight(x, y);

                    if (h < 0.1f)
                    {
                        tileMap[x, y] = TileType.DeepWater;
                    }
                    else if (h < 0.2f)
                    {
                        tileMap[x, y] = TileType.Water;
                    }
                    else if (h < 0.45f)
                    {
                        tileMap[x, y] = TileType.Sand;
                    }
                    else if (h < 0.55f)
                    {
                        tileMap[x, y] = TileType.Dirt;
                    }
                    else if (h < 0.8f)
                    {
                        tileMap[x, y] = TileType.Grass;
                    }
                    else if (h < 0.9f)
                    {
                        tileMap[x, y] = TileType.Rock;
                    }
                    else
                    {
                        tileMap[x, y] = TileType.Snow;
                    }
                }
            }
        }

        private static void GenerateConnections(TileMapSettings settings, TileMap tileMap)
        {
            var firstConnection = false;
            var allDirs = new Vec2i[] { new Vec2i(1, 0), new Vec2i(0, 1), new Vec2i(-1, 0), new Vec2i(0, -1) };

            var dirIdx = new Random().Next(0, allDirs.Length);
            var currentDir = allDirs[dirIdx];

            var connections = new List<Vec2i>();
            for (var i = 0; i < allDirs.Length; i++)
            {
                if (!firstConnection || new Random().Next(0, 100) > 30)
                {
                    firstConnection = true;
                    connections.Add(currentDir);
                    dirIdx = (dirIdx + 1) % allDirs.Length;
                    currentDir = allDirs[dirIdx];
                }
            }

            var maxOffset = settings.size - (settings.borderConnectionSize * 2);

            foreach (var connectionDir in connections)
            {
                var rnd = new Random().Next(0, maxOffset) + settings.borderConnectionSize;

                var x = (int)(connectionDir.x == 0 ? rnd : (connectionDir.x == -1 ? 0 : settings.size - settings.borderConnectionSize - 1));
                var y = (int)(connectionDir.y == 0 ? rnd : (connectionDir.y == -1 ? 0 : settings.size - settings.borderConnectionSize - 1));

                CreateSquare(tileMap, x, y, settings.borderConnectionSize, settings.borderConnectionSize, true);
            }

        }

        private static void CreateSquare(TileMap tileMap, int x, int y, int width, int height, bool softBorders)
        {
            var rect = new Rect2i(x, y, width, height);
            var halfRect = rect.end - rect.start;
            var mapRect = new Rect2i(0, 0, tileMap.Size, tileMap.Size);

            if (!mapRect.Contains(rect.start) || !mapRect.Contains(rect.end))
                return;

            for (var px = rect.start.x; px < rect.end.x; px++)
            {
                for (var py = rect.start.y; py < rect.end.y; py++)
                {
                    var p = new Vec2i(px, py);

                    if (!mapRect.Contains(p))
                        continue;

                    var h = tileMap.GetHeight(px, py);
                    var dist = (float)(p - rect.center).Magnitude();
                    var diff = (halfRect.Magnitude() - dist) / halfRect.Magnitude();
                    var diff_h = h - 0.5f;
                    h -= diff_h * diff;

                    tileMap.SetHeight(px, py, h);
                }
            }

            var allDirs = new Vec2i[] { new Vec2i(1, 0), new Vec2i(0, 1), new Vec2i(-1, 0), new Vec2i(0, -1) };

            var heightBufferBak = new float[tileMap.Size * tileMap.Size];
            Array.Copy(tileMap.HeightBuffer, heightBufferBak, heightBufferBak.Length);

            var borderThickness = (int)(width * 0.25f);
            var borderRect = rect.Expand(borderThickness);

            var point = borderRect.start;
            var walkLeft = borderRect.Width() - 1;
            var dirCnt = 0;
            var dir = allDirs[dirCnt];
            var dirMod = 0;

            while (true)
            {
                if (mapRect.Contains(point))
                {
                    SmoothPixel(tileMap, point, heightBufferBak);
                }

                walkLeft -= 1;

                if (walkLeft <= 0)
                {
                    dirMod += 1;
                    dir = allDirs[dirMod % allDirs.Length];
                    walkLeft = borderRect.Width() - (int)(dirMod / 3) - 1;
                    if (walkLeft < 0)
                        break;

                    point += dir;
                }
            }

        }

        private static void SmoothPixel(TileMap tileMap, Vec2i point, float[] heightBufferBak)
        {
            var h = 0.0f;
            var count = 0;

            for (var i = -2; i < 3; i++)
            {
                for (var k = -2; k < 3; k++)
                {
                    var px = new Vec2i(point.x + i, point.y + k);
                    var idx = tileMap.ToIndex(px);

                    if (idx < 0 || idx >= heightBufferBak.Length)
                        continue;

                    h += heightBufferBak[idx];
                    count += 1;

                }
            }

            if (count > 0)
                tileMap.SetHeight(point, h / count);
        }

        private static void GenerateBorder(TileMapSettings settings, TileMap tileMap)
        {
            var borderLeft = settings.borderSize;
            var borderUp = settings.borderSize;
            var borderRight = settings.size - settings.borderSize;
            var borderDown = settings.size - settings.borderSize;

            for (var x = 0; x < settings.size; x++)
            {
                for (var y = 0; y < settings.size; y++)
                {
                    if (x > borderLeft && x < borderRight && y > borderUp && y < borderDown)
                        continue;

                    var borderThicknessX = 0;

                    if (x < borderLeft)
                        borderThicknessX = borderLeft - x;
                    else if (x > borderRight)
                        borderThicknessX = x - borderRight;

                    var borderThicknessY = 0;

                    if (y < borderUp)
                        borderThicknessY = borderUp - y;
                    else if (y > borderDown)
                        borderThicknessY = y - borderDown;

                    var h = tileMap.GetHeight(x, y);
                    var maxThickness = Math.Max(borderThicknessX, borderThicknessY);
                    var rate = maxThickness * 1.3f / (float)settings.borderSize;

                    rate = GMath.Clamp(0, 1, rate);

                    if (settings.borderMontains)
                    {
                        h += (1 - h) * rate;
                    }
                    else
                    {
                        h -= h * rate;
                    }

                    tileMap.SetHeight(x, y, h);
                }
            }
        }

        private static void GenerateHeightMap(TileMapSettings settings, TileMap tileMap)
        {
            FastNoiseLite fastNoise = new FastNoiseLite();
            fastNoise.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2);
            fastNoise.SetSeed(DateTime.Now.Second);

            fastNoise.SetFrequency(settings.frequency);
            fastNoise.SetFractalOctaves(settings.fractalOctaves);
            fastNoise.SetFractalLacunarity(settings.fractalLacunarity);
            fastNoise.SetFractalGain(settings.fractalGain);
            fastNoise.SetFractalType(FastNoiseLite.FractalType.FBm);

            var min = 0.0f;
            var max = 0.0f;

            for (var x = 0; x < settings.size; x++)
            {
                for (var y = 0; y < settings.size; y++)
                {
                    var height = fastNoise.GetNoise(x / (float)settings.size, y / (float)settings.size);
                    tileMap.SetHeight(x, y, height);

                    if (height < min)
                    {
                        min = height;
                    }
                    else if (height > max)
                    {
                        max = height;
                    }
                }
            }

            for (var x = 0; x < settings.size; x++)
            {
                for (var y = 0; y < settings.size; y++)
                {
                    tileMap.SetHeight(x, y, GMath.InverseLerp(min, max, tileMap.GetHeight(x, y)));
                }
            }
        }
    }
}
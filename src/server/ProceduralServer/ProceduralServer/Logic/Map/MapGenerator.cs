using CommonLib.Logic.Map;
using CommonLib.Util;
using CommonLib.Util.Math;
using System;
using System.Collections.Generic;

namespace ProceduralServer.Logic.Map
{
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

        public bool[] hasSurroundingConnections;
        public Vec2[] surroundingConnections;
    }

    class TileMap
    {
        public TileMap(int size)
        {
            _size = size;
            _tileType = new byte[size * size];
            _heightMap = new byte[size * size];
        }

        private readonly int _size;
        public int Size
        {
            get => _size;
        }

        public byte[] _heightMap;
        private byte[] _tileType;

        public byte[] HeightBuffer { get => _heightMap; }
        public byte[] TileBuffer { get => _tileType; }
        public Vec2[] Connections { get; internal set; }

        public void SetHeight(int x, int y, byte height)
        {
            _heightMap[x + y * _size] = height;
        }

        public float GetHeight(int x, int y)
        {
            return _heightMap[x + y * _size];
        }

        public void SetHeight(Vec2 pos, byte height)
        {
            _heightMap[pos.x + pos.y * _size] = height;
        }

        public float GetHeight(Vec2 pos)
        {
            return _heightMap[pos.x + pos.y * _size];
        }

        public int ToIndex(Vec2 pos)
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
            var random = new Random(settings.position.GetHashCode());
            var tileMap = new TileMap(settings.size);

            var tmp = new float[settings.size * settings.size];

            GenerateHeightMap(settings, tmp);
            GenerateBorder(settings, tmp);
            var connections = GenerateConnections(settings, tmp);

            tileMap._heightMap = CompressionHelper.CompressLossy2Precision(tmp);
            tileMap.Connections = connections;

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

                    if (h <= 10)
                    {
                        tileMap[x, y] = TileType.DeepWater;
                    }
                    else if (h <= 20)
                    {
                        tileMap[x, y] = TileType.Water;
                    }
                    else if (h <= 45)
                    {
                        tileMap[x, y] = TileType.Sand;
                    }
                    else if (h <= 55)
                    {
                        tileMap[x, y] = TileType.Dirt;
                    }
                    else if (h <= 80)
                    {
                        tileMap[x, y] = TileType.Grass;
                    }
                    else if (h <= 90)
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

        private static Vec2[] GenerateConnections(TileMapSettings settings, float[] heightMap)
        {
            var connectionCnt = 0;
            var connections = new Vec2[] { Vec2.INVALID, Vec2.INVALID, Vec2.INVALID, Vec2.INVALID };

            for (var i = 0; i < settings.surroundingConnections.Length; i++)
            {
                var exitingConnection = settings.surroundingConnections[i];
                var hasExistingConnections = settings.hasSurroundingConnections[i];

                if (hasExistingConnections && exitingConnection.IsValid())
                {
                    var maxOffset = (short)(settings.size - settings.borderConnectionSize);

                    //Since the existing info is from neighbors map, we need to reverse it in order to use 
                    //left connection on left map is my right connection

                    if (exitingConnection.x == 0)
                        exitingConnection.x = maxOffset;
                    else if (exitingConnection.x == maxOffset)
                        exitingConnection.x = 0;

                    if (exitingConnection.y == 0)
                        exitingConnection.y = maxOffset;
                    else if (exitingConnection.y == maxOffset)
                        exitingConnection.y = 0;

                    CreateSquare(settings, heightMap, exitingConnection.x, exitingConnection.y, settings.borderConnectionSize, settings.borderConnectionSize);
                    connectionCnt++;
                    connections[i] = exitingConnection;
                }
                else if(!hasExistingConnections)
                {
                    var rnd = new Random(settings.position.GetHashCode()).Next(0, 100);
                    var rate = (connectionCnt == 0) ? (i * 15) + 50 : 50;

                    if (rnd < rate)
                    {
                        var dir = Vec2.ALL_DIRS[i];
                        connections[i] = GenerateConnection(settings, heightMap, dir);
                        connectionCnt++;
                    }
                }
            }

            return connections;
        }

        private static Vec2 GenerateConnection(TileMapSettings settings, float[] heightMap, Vec2 connectionDir)
        {
            var maxOffset = settings.size - (settings.borderConnectionSize * 2);

            var rnd = new Random(settings.position.GetHashCode()).Next(0, maxOffset) + settings.borderConnectionSize;

            var cx = (int)(connectionDir.x == 0 ? rnd : (connectionDir.x == -1 ? 0 : settings.size - settings.borderConnectionSize));
            var cy = (int)(connectionDir.y == 0 ? rnd : (connectionDir.y == -1 ? 0 : settings.size - settings.borderConnectionSize));

            CreateSquare(settings, heightMap, cx, cy, settings.borderConnectionSize, settings.borderConnectionSize);

            return new Vec2(cx, cy);
        }

        private static void CreateSquare(TileMapSettings settings, float[] heightMap, int x, int y, int width, int height)
        {
            var rect = new Rect2i(x, y, width, height);
            var halfRect = rect.end - rect.start;
            var mapRect = new Rect2i(0, 0, settings.size, settings.size);

            if (!mapRect.Contains(rect.start) || !mapRect.Contains(rect.end))
                return;

            for (var px = rect.start.x; px < rect.end.x; px++)
            {
                for (var py = rect.start.y; py < rect.end.y; py++)
                {
                    var p = new Vec2(px, py);

                    if (!mapRect.Contains(p))
                        continue;

                    var h = heightMap[px + py * settings.size];
                    var dist = (float)(p - rect.center).Magnitude();
                    var diff = (halfRect.Magnitude() - dist) / halfRect.Magnitude();
                    var diff_h = h - 0.5f;
                    h -= diff_h * diff;

                    heightMap[px + py * settings.size] = h;
                }
            }

            var heightBufferBak = new float[settings.size * settings.size];
            Array.Copy(heightMap, heightBufferBak, heightBufferBak.Length);

            var borderThickness = (int)(width * 0.25f);
            var borderRect = rect.Expand(borderThickness);

            var point = borderRect.start;
            var walkLeft = borderRect.Width() - 1;
            var dirMod = 0;

            while (true)
            {
                if (mapRect.Contains(point))
                {
                    SmoothPixel(settings, heightMap, point, heightBufferBak);
                }

                walkLeft -= 1;

                if (walkLeft <= 0)
                {
                    dirMod += 1;
                    var dir = Vec2.ALL_DIRS[dirMod % Vec2.ALL_DIRS.Length];
                    walkLeft = borderRect.Width() - (int)(dirMod / 3) - 1;
                    if (walkLeft < 0)
                        break;

                    point += dir;
                }
            }

        }

        private static void SmoothPixel(TileMapSettings settings, float[] heightMap, Vec2 point, float[] heightBufferBak)
        {
            var h = 0.0f;
            var count = 0;

            for (var i = -2; i < 3; i++)
            {
                for (var k = -2; k < 3; k++)
                {
                    var px = new Vec2(point.x + i, point.y + k);
                    var idx = px.x + px.y * settings.size;

                    if (idx < 0 || idx >= heightBufferBak.Length)
                        continue;

                    h += heightBufferBak[idx];
                    count += 1;

                }
            }

            if (count > 0)
                heightMap[point.x + point.y * settings.size] = (h / count);
        }

        private static void GenerateBorder(TileMapSettings settings, float[] heightMap)
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

                    var h = heightMap[x + y * settings.size];
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

                    heightMap[x + y * settings.size] = h;
                }
            }
        }

        private static void GenerateHeightMap(TileMapSettings settings, float[] heightMap)
        {
            FastNoiseLite fastNoise = new FastNoiseLite();
            fastNoise.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2);
            fastNoise.SetSeed(settings.position.GetHashCode());

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
                    heightMap[x + y * settings.size] = height;

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
                    heightMap[x + y * settings.size] = GMath.InverseLerp(min, max, heightMap[x + y * settings.size]);
                }
            }
        }
    }
}
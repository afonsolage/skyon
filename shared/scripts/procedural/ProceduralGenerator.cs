using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Godot;

public class ProceduralGenerator : Godot.Object
{
    enum Directions3D
    {
        RIGHT,
        LEFT,
        FRONT,
        BACK,
        UP,
        DOWN,
    }

    public const int MinMapMargin = 2;

    public readonly Vector3[] Dirs3D = new Vector3[] { Vector3.Right, Vector3.Left, Vector3.Forward, Vector3.Back, Vector3.Up, Vector3.Down };

    public readonly Vector2[] Dirs2D = new Vector2[] { Vector2.Right, Vector2.Up, Vector2.Left, Vector2.Down };

    private Vector3 V1(Vector3 p) => new Vector3(p.x, p.y + 1, p.z);
    private Vector3 V2(Vector3 p) => new Vector3(p.x + 1, p.y + 1, p.z);
    private Vector3 V3(Vector3 p) => new Vector3(p.x, p.y + 1, p.z + 1);
    private Vector3 V4(Vector3 p) => new Vector3(p.x + 1, p.y + 1, p.z + 1);
    private Vector3 V5(Vector3 p) => new Vector3(p.x, p.y, p.z);
    private Vector3 V6(Vector3 p) => new Vector3(p.x + 1, p.y, p.z);
    private Vector3 V7(Vector3 p) => new Vector3(p.x, p.y, p.z + 1);
    private Vector3 V8(Vector3 p) => new Vector3(p.x + 1, p.y, p.z + 1);



    public ProceduralGenerator(ProceduralGeneratorSettings settings)
    {
        Settings = settings;
    }

    public ProceduralGenerator()
    {
    }

    public ProceduralGeneratorSettings Settings { get; set; }

    private Random _rnd;
    private Rect2 _mapRect;

    public void GenerateCollisions(Map2D map)
    {
        var collisions = new List<Vector3>();
        var planes = CreatePlanes(map.HeightMap);
        var indices = CreateIndices(planes);

        var vertices = new List<Vector3>();

        foreach (var vertexList in planes)
        {
            vertices.AddRange(vertexList);
        }

        foreach (var index in indices)
        {
            collisions.Add(vertices[index]);
        }

        map.Collisions = collisions.ToArray();
    }

    private int[] CreateIndices(List<Vector3>[] planes)
    {
        var indices = new List<int>();

        var n = 0;
        foreach (var vertices in planes)
        {
            for (var k = 0; k < vertices.Count(); k += 4)
            {
                indices.Add(n);
                indices.Add(n + 1);
                indices.Add(n + 3);

                indices.Add(n + 1);
                indices.Add(n + 2);
                indices.Add(n + 3);

                n += 4;
            }
        }

        return indices.ToArray();
    }

    private List<Vector3>[] CreatePlanes(MapBuffer2D<byte> heightMap)
    {
        var planes = new List<Vector3>[5]; //There is no down faces
        planes[(int)Directions3D.RIGHT] = new List<Vector3>();
        planes[(int)Directions3D.LEFT] = new List<Vector3>();
        planes[(int)Directions3D.FRONT] = new List<Vector3>();
        planes[(int)Directions3D.BACK] = new List<Vector3>();

        for (var i = 0; i < heightMap.BufferSize(); i++)
        {
            var position = heightMap.ToPosition(i);
            var height = heightMap[i];
            var position3D = new Vector3(position.x, height, position.y);

            for (var dir = (int)Directions3D.RIGHT; dir <= (int)Directions3D.BACK; dir++)
            {
                var vertices = CalcVertices(heightMap, dir, position3D);
                if (vertices != null)
                    planes[dir].AddRange(vertices);
            }
        }

        planes[(int)Directions3D.UP] = MergeUpFaces(heightMap);
        return planes;
    }

    private List<Vector3> MergeUpFaces(MapBuffer2D<byte> heightMap)
    {
        var merged = new byte[heightMap.BufferSize()];
        var mergedFaces = new List<Vector3>();

        for (var x = 0; x < heightMap.AxisSize(); x++)
        {
            for (var z = 0; z < heightMap.AxisSize(); z++)
            {
                var index = heightMap.ToIndex(x, z);

                if (merged[index] == 1)
                {
                    continue;
                }

                var height = heightMap[index];
                var originX = x;
                var originZ = z;

                var endZ = originZ + 1;
                while (endZ < heightMap.AxisSize())
                {
                    var nextIndex = heightMap.ToIndex(originX, endZ);
                    var nextHeight = heightMap[nextIndex];

                    if (nextHeight == height && merged[nextIndex] == 0)
                    {
                        endZ++;
                    }
                    else
                    {
                        break;
                    }
                }
                endZ--;

                var endX = originX;
                var done = false;
                while (endX < heightMap.AxisSize() & !done)
                {
                    endX++;

                    if (endX >= heightMap.AxisSize())
                    {
                        break;
                    }

                    for (var tmpZ = originZ; tmpZ <= endZ; tmpZ++)
                    {
                        var nextIndex = heightMap.ToIndex(endX, tmpZ);
                        var nextHeight = heightMap[nextIndex];

                        if (nextHeight != height || merged[nextIndex] == 1)
                        {
                            done = true;
                            break;
                        }
                    }
                }

                endX--;

                for (var mergedX = originX; mergedX <= endX; mergedX++)
                {
                    for (var mergedZ = originZ; mergedZ <= endZ; mergedZ++)
                    {
                        merged[heightMap.ToIndex(mergedX, mergedZ)] = 1;
                    }
                }

                mergedFaces.Add(V1(new Vector3(originX, height, originZ)));
                mergedFaces.Add(V2(new Vector3(endX, height, originZ)));
                mergedFaces.Add(V4(new Vector3(endX, height, endZ)));
                mergedFaces.Add(V3(new Vector3(originX, height, endZ)));
            }
        }

        return mergedFaces;
    }

    private Vector3[] CalcVertices(MapBuffer2D<byte> heightMap, int dir, Vector3 position)
    {
        var height = CalcHeightDifference(heightMap, dir, position);

        if (height <= 0)
        {
            return null;
        }

        var heightExtend = new Vector3(0, height - 1, 0);

        switch ((Directions3D)dir)
        {
            case Directions3D.RIGHT:
                return new Vector3[] { V4(position), V2(position), V6(position - heightExtend), V8(position - heightExtend) };
            case Directions3D.LEFT:
                return new Vector3[] { V1(position), V3(position), V7(position - heightExtend), V5(position - heightExtend) };
            case Directions3D.FRONT:
                return new Vector3[] { V1(position), V5(position - heightExtend), V6(position - heightExtend), V2(position) };
            case Directions3D.BACK:
                return new Vector3[] { V3(position), V4(position), V8(position - heightExtend), V7(position - heightExtend) };
            default:
                return null;
        }
    }

    private int CalcHeightDifference(MapBuffer2D<byte> heightMap, int dir, Vector3 position)
    {
        var normal = CalcNormal(dir);
        var nextIndex = heightMap.ToIndex(new Vector2(position.x + normal.x, position.z + normal.z));
        if (nextIndex >= 0 && nextIndex < heightMap.BufferSize())
        {
            var nextHeight = heightMap[nextIndex];
            return (int)position.y - nextHeight;
        }

        return 0;
    }

    private Vector3 CalcNormal(int dir)
    {
        return Dirs3D[dir];
    }

    public Map2D GenerateMap2D()
    {
        _rnd = new Random(Settings.Seed);
        _mapRect = new Rect2(MinMapMargin, MinMapMargin, Settings.Size - MinMapMargin * 2, Settings.Size - MinMapMargin * 2);

        var heightMap = new MapBuffer2D<float>(Settings.Size);
        var map2D = new Map2D();

        if (Settings.IsGenerateHeight)
        {
            GenerateHeightMap(heightMap);
        }

        if (Settings.IsGenerateBorder)
        {
            GenerateBorder(heightMap);
        }

        if (Settings.IsGenerateConnections)
        {
            map2D.Connections = GenerateConnections(heightMap);
        }

        NormalizeHeightMap(heightMap);
        map2D.HeightMap = ScaleHeightMap(heightMap);

        return map2D;
    }

    private MapBuffer2D<byte> ScaleHeightMap(MapBuffer2D<float> heightMap)
    {
        var scaledMap = new MapBuffer2D<byte>(heightMap.AxisSize());

        for (var i = 0; i < heightMap.BufferSize(); i++)
        {
            var height = heightMap[i];
            var scaledHeight = (int)(height * Settings.MapScale);
            scaledMap[i] = (byte)scaledHeight;
        }

        return scaledMap;
    }

    private void NormalizeHeightMap(MapBuffer2D<float> heightMap)
    {
        for (var i = 0; i < heightMap.BufferSize(); i++)
        {
            var height = heightMap[i];
            height = (height + 1.0f) / 2.0f;
            heightMap[i] = Mathf.Clamp(height, 0.0f, 1.0f);
        }
    }

    private Vector2[] GenerateConnections(MapBuffer2D<float> heightMap)
    {
        var minOffset = MinMapMargin;
        var maxOffset = Settings.Size - Settings.BorderConnectionSize - minOffset;
        var invalid = new Vector2(-1, -1);

        var connectionCount = Settings.ExistingConnections.Where(c => c != Vector2.Zero && c != invalid).Count();
        var connections = new Vector2[4];

        for (var i = 0; i < Dirs2D.Length; i++)
        {
            var existingConnection = Settings.ExistingConnections[i];
            var dir = Dirs2D[i];

            if (existingConnection == invalid)
            {
                continue;
            }
            else if (existingConnection == Vector2.Zero)
            {
                var rnd = _rnd.Next() % 100;
                var rate = connectionCount == 0 ? 100 : 100 - (connectionCount * 20);
                if (rnd < rate)
                {
                    connections[i] = GenerateConnection(heightMap, dir);
                }
                else
                {
                    connections[i] = invalid;
                }
            }
            else
            {
                if (existingConnection.x == minOffset)
                {
                    existingConnection.x = maxOffset;
                }
                else if (existingConnection.x == maxOffset)
                {
                    existingConnection.x = minOffset;
                }

                if (existingConnection.y == minOffset)
                {
                    existingConnection.y = maxOffset;
                }
                else if (existingConnection.y == maxOffset)
                {
                    existingConnection.y = minOffset;
                }

                existingConnection += dir * -1 * MinMapMargin;

                CreateSquare((int)existingConnection.x, (int)existingConnection.y, Settings.BorderConnectionSize, Settings.BorderConnectionSize, heightMap);

                connections[i] = existingConnection;
            }
        }

        return ConnectConnections(heightMap, connections);
    }

    private Vector2[] ConnectConnections(MapBuffer2D<float> heightMap, Vector2[] connections)
    {
        var range = (int)(Settings.Size * 0.05f);
        var offsetX = _rnd.Next() % (range * 2) - range; // Since Next only returns positive numbers, we modulus 2 times the range and subtract
        var offsetY = _rnd.Next() % (range * 2) - range;
        var center = new Vector2(Settings.Size / 2.0f + offsetX, Settings.Size / 2.0f + offsetY);

        // We need to add a offset, since the connection is always at left bottom of the connection square
        var connectionOffset = new Vector2(Settings.BorderConnectionSize / 2.0f, Settings.BorderConnectionSize / 2.0f);

        var validConnections = connections.Where(c => c != Vector2.Zero && c != new Vector2(-1, -1));
        foreach (var connection in validConnections)
        {
            GeneratePath(connection + connectionOffset, center, heightMap);
        }

        return connections;
    }

    private void GeneratePath(Vector2 from, Vector2 to, MapBuffer2D<float> heightMap)
    {
        float calc_dist(Vector2 a, Vector2 b) => (a - b).Length();

        var queue = new Queue<(Vector2, float)>();
        var walked = new HashSet<Vector2>();

        queue.Enqueue((from, calc_dist(from, to)));

        while (queue.Count > 0)
        {
            var (point, _) = queue.Dequeue();
            walked.Add(point);

            if (point == to)
            {
                DrawPath(walked, heightMap);
                return;
            }

            var noised = false;
            foreach (var dir in Dirs2D)
            {
                var nextPoint = point + dir;

                if (!_mapRect.HasPoint(nextPoint) || walked.Contains(nextPoint))
                {
                    continue;
                }

                if (!noised && _rnd.Next() % 100 < Settings.PathNoiseRate)
                {
                    noised = true;
                    continue;
                }

                queue.Enqueue((nextPoint, calc_dist(nextPoint, to)));
            }

            queue = new Queue<(Vector2, float)>(queue.OrderBy(t => t.Item2));
        }
    }

    private void DrawPath(HashSet<Vector2> path, MapBuffer2D<float> heightMap)
    {
        // First set the raw values
        foreach (var point in path)
        {
            foreach (var dir in Dirs2D)
            {
                for (var i = 0; i < Settings.PathThickness; i++)
                {
                    var p = point + dir * i;
                    if (_mapRect.HasPoint(p))
                    {
                        heightMap[p] = 0.5f;
                    }
                }
            }
        }

        // Now smooth it
        foreach (var point in path)
        {
            foreach (var dir in Dirs2D)
            {
                for (var i = 0; i < Settings.PathThickness; i++)
                {
                    var p = point + dir * i;
                    if (_mapRect.HasPoint(p))
                    {
                        SmoothPixel(p, heightMap);
                    }
                }
            }
        }
    }

    private void SmoothPixel(Vector2 pixel, MapBuffer2D<float> heightMap)
    {
        var height = 0.0f;
        var pixelCount = 0;

        for (var i = -1; i < 2; i++)
        {
            for (var k = -1; k < 2; k++)
            {
                var point = new Vector2(pixel.x + i, pixel.y + k);

                if (!_mapRect.HasPoint(point))
                {
                    continue;
                }

                height += heightMap[point];
                pixelCount++;
            }
        }

        if (pixelCount > 0)
        {
            heightMap[pixel] = height / (float)pixelCount;
        }
    }

    private void CreateSquare(int sx, int sy, int width, int height, MapBuffer2D<float> heightMap)
    {
        var squareRect = new Rect2(sx, sy, width, height);

        if (!_mapRect.Encloses(squareRect))
        {
            return;
        }

        for (var x = squareRect.Position.x; x <= squareRect.End.x; x++)
            for (var y = squareRect.Position.y; y <= squareRect.End.x; y++)
            {
                var point = new Vector2(x, y);

                if (!_mapRect.HasPoint(point))
                {
                    continue;
                }

                var h = 0.5f; // TODO: Find a better place to get this;
                heightMap[point] = h;
            }
    }

    private Vector2 GenerateConnection(MapBuffer2D<float> heightMap, Vector2 dir)
    {
        var maxOffset = Settings.Size - Settings.BorderConnectionSize;
        var rnd = _rnd.Next() % Settings.Size;
        rnd = Mathf.Clamp(rnd, Settings.BorderConnectionSize * 2, maxOffset + Settings.BorderConnectionSize);

        var connectionX = dir.x == 0 ? rnd : dir.x == -1 ? 0 : maxOffset;
        var connectionY = dir.y == 0 ? rnd : dir.y == -1 ? 0 : maxOffset;

        var offset = dir * -1 * MinMapMargin;

        connectionX += (int)offset.x;
        connectionY += (int)offset.y;

        CreateSquare(connectionX, connectionY, Settings.BorderConnectionSize, Settings.BorderConnectionSize, heightMap);

        return new Vector2(connectionX, connectionY);
    }

    private void GenerateBorder(MapBuffer2D<float> heightMap)
    {
        var borderLeft = Settings.BorderSize;
        var borderUp = borderLeft;
        var borderRight = Settings.Size - borderLeft - 1;
        var borderDown = Settings.Size - borderUp - 1;

        var innerRect = new Rect2(borderLeft, borderUp, borderRight - borderLeft, borderDown - borderUp);

        for (var i = 0; i < heightMap.BufferSize(); i++)
        {
            var position = heightMap.ToPosition(i);

            if (innerRect.HasPoint(position))
            {
                continue;
            }

            var borderThicknessX = 0;

            if (position.x < borderLeft)
            {
                borderThicknessX = borderLeft - (int)position.x;
            }
            else if (position.x > borderRight)
            {
                borderThicknessX = (int)position.x - borderRight;
            }

            var borderThicknessY = 0;

            if (position.y < borderUp)
            {
                borderThicknessY = borderUp - (int)position.y;
            }
            else if (position.y > borderDown)
            {
                borderThicknessY = (int)position.y - borderDown;
            }

            var borderThickness = (float) Mathf.Max(borderThicknessX, borderThicknessY);
            borderThickness *= Settings.BorderThickness;
            borderThickness *= Settings.IsBorderMountains ? 1 : -1;

            var height = heightMap[position];
            height += borderThickness;
            heightMap[i] = height;
        }
    }

    private void GenerateHeightMap(MapBuffer2D<float> heightMap)
    {
        var noise = new OpenSimplexNoise
        {
            Seed = _rnd.Next(),
            Octaves = Settings.Octaves,
            Period = Settings.Period,
            Persistence = Settings.Persistance,
        };

        for (var i = 0; i < heightMap.BufferSize(); i++)
        {
            var position = heightMap.ToPosition(i);
            var height = (noise.GetNoise3d(position.x, 0, position.y) + 1.0f) / 2.0f;
            heightMap[i] = height;
        }
    }
}

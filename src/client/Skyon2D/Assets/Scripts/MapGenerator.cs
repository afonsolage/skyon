using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;



public class HeightMap<T>
{
    public uint size;
    private T[] _type;

    public void Allocate(uint size)
    {
        _type = new T[size * size];
        this.size = size;
    }

    public T this[int i]
    {
        get { return _type[i]; }
        set { _type[i] = value; }
    }

    public T this[int x, int y]
    {
        get { return _type[x + y * size]; }
        set { _type[x + y * size] = value; }
    }
}

public class MapGenerator : MonoBehaviour
{
    private static readonly Vector2[] DIRS = new Vector2[] { Vector2.up, Vector2.right, Vector2.down, Vector2.left };

    public SpriteRenderer SpriteRenderer;

    public uint mapSize = 1024;

    public float scale = 1.0f;
    public int octaves = 2;
    public float persistance = .3f;
    public float lacunarity = 20.0f;

    public int borderSize = 50;
    public float borderThickness = 0.05f;
    public bool borderMontains = false;

    public int borderConnectionSize = 8;
    public int placesCount = 5;
    public int placesPathNoiseRate = 40;
    public int placesPathThickness = 15;
    public bool smoothConnectionBorder = true;
    public bool generatePlaces = true;
    public bool connectPlaces = true;

    public bool colorizeMap = true;

    private HeightMap<float> _Map;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void Generate()
    {
        _Map = new HeightMap<float>();
        _Map.Allocate(mapSize);

        GenerateHeightMap();
        GenerateBorder();
        GeneratePlaces();

        Draw();
    }

    private void GenerateHeightMap()
    {
        var min = 0.0f;
        var max = 0.0f;

        for (var x = 0; x < _Map.size; x++)
        {
            for (var y = 0; y < _Map.size; y++)
            {
                var height = BetterNoise(x, y, scale, octaves, persistance, lacunarity);
                _Map[x, y] = height;

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

        for (var x = 0; x < _Map.size; x++)
        {
            for (var y = 0; y < _Map.size; y++)
            {
                _Map[x, y] = Mathf.InverseLerp(min, max, _Map[x, y]);
            }
        }
    }

    public float BetterNoise(int x, int y, float scale, int octaves, float persistance, float lacunarity)
    {
        var amplitude = 1.0f;
        var frequency = 1.0f;
        var finalHeight = 1.0f;

        for (var i = 0; i < octaves; i++)
        {
            var sampleX = x / scale * frequency;
            var sampleY = y / scale * frequency;

            var height = Mathf.PerlinNoise(sampleX, sampleY) * 2 - 1;
            finalHeight += height * amplitude;

            amplitude *= persistance;
            frequency *= lacunarity;
        }

        return finalHeight;
    }

    public void GenerateBorder()
    {
        var borderLeft = borderSize;
        var borderUp = borderSize;
        var borderRight = (int)_Map.size - borderSize;
        var borderDown = (int)_Map.size - borderSize;

        for (var x = 0; x < _Map.size; x++)
        {
            for (var y = 0; y < _Map.size; y++)
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

                var h = _Map[x, y];
                h += Mathf.Max(borderThicknessX, borderThicknessY) * (borderThickness * (borderMontains ? 1 : -1));
                _Map[x, y] = h;
            }
        }
    }

    public void GeneratePlaces()
    {
        var offset = _Map.size / (borderSize / 2);
        var firstConnection = false;

        var dirIdx = Random.Range(0, DIRS.Length - 1);
        var currentDir = DIRS[dirIdx];

        var connections = new List<Vector2>();
        var places = new List<Vector2>();

        for (int i = 0; i < DIRS.Length; i++)
        {
            if (!firstConnection || Random.Range(0, 100) > 30)
            {
                firstConnection = true;
                connections.Add(currentDir);
                dirIdx = (dirIdx + 1) % DIRS.Length;
                currentDir = DIRS[dirIdx];
            }
        }

        var maxOffset = _Map.size - (borderConnectionSize * 3);

        foreach (var connectionDir in connections)
        {
            var rnd = Random.Range(0, maxOffset) + borderConnectionSize;

            var x = (int)(connectionDir.x == 0 ? rnd : (connectionDir.x == -1 ? 0 : _Map.size - borderConnectionSize - 1));
            var y = (int)(connectionDir.y == 0 ? rnd : (connectionDir.y == -1 ? 0 : _Map.size - borderConnectionSize - 1));

            CreateSquare(x, y, borderConnectionSize, borderConnectionSize, true);
            places.Add(new Vector2(x + borderConnectionSize / 2, y + borderConnectionSize / 2));
        }

        if (generatePlaces)
        {
            for (var i = 0; i < placesCount; i++)
            {
                var x = (int)Random.Range(offset, _Map.size - offset * 3);
                var y = (int)Random.Range(offset, _Map.size - offset * 3);
                var w = (int)Random.Range(offset, offset * 2);
                var h = (int)Random.Range(offset, offset * 2);

                CreateSquare(x, y, w, h, false);
                places.Add(new Vector2(x + w / 2, y + h / 2));
            }
        }

        if (connectPlaces)
            ConnectPlaces(places);
    }

    public void ConnectPlaces(List<Vector2> places)
    {
        var queue = new Queue<Vector2>(places);

        while (queue.Count > 0)
        {
            var point = queue.Dequeue();

            if (queue.Count == 0)
                break;

            queue = new Queue<Vector2>(queue.OrderBy(p => (point - p).magnitude));
            GeneratePath(point, queue.First());
        }
    }

    public void GeneratePath(Vector2 origin, Vector2 dest)
    {
        var queue = new Queue<Vector2>();
        var walked = new List<Vector2>();

        queue.Enqueue(origin);

        while (queue.Count > 0)
        {
            var point = queue.Dequeue();
            walked.Add(point);

            if (point == dest)
            {
                DrawPath(walked);
                return;
            }

            var addedNoise = false;

            foreach (var dir in DIRS)
            {
                var nextPoint = point + dir;

                if (!addedNoise && Random.Range(0, 100) < placesPathNoiseRate)
                {
                    addedNoise = true;
                    continue;
                }

                if (!walked.Contains(nextPoint))
                {
                    queue.Enqueue(nextPoint);
                }
            }

            queue = new Queue<Vector2>(queue.OrderBy(p => (dest - p).magnitude));
        }

    }

    public void DrawPath(List<Vector2> path)
    {
        var mapRect = new Rect(0, 0, _Map.size, _Map.size);

        foreach (var p in path)
        {
            foreach (var dir in DIRS)
            {
                for (var i = 0; i < placesPathThickness; i++)
                {
                    var point = p + (dir * i);
                    if (mapRect.Contains(point))
                    {
                        _Map[(int)point.x, (int)point.y] = 0.5f; //TODO: Find a better place to set it;
                    }
                }
            }
        }

        //var mapBak = new Dictionary<Vector2Int, float>();
        //foreach (var p in path)
        //{
        //    foreach (var dir in DIRS)
        //    {
        //        for (var i = 0; i < placesPathThickness * 2; i++)
        //        {
        //            var point = p + (dir * i);
        //            if (mapRect.Contains(point))
        //            {
        //                var pInt = new Vector2Int((int)point.x, (int)point.y);
        //                mapBak[pInt] = _Map[pInt.x, pInt.y];
        //            }
        //        }
        //    }
        //}

        //foreach (var p in path)
        //{
        //    foreach (var dir in DIRS)
        //    {
        //        for (var i = 0; i < placesPathThickness; i++)
        //        {
        //            var point = p + (dir * i);
        //            if (mapRect.Contains(point))
        //            {
        //                SmoothPixel((int)point.x, (int)point.y, mapBak);
        //            }
        //        }
        //    }
        //}
    }

    public void CreateSquare(int x, int y, int width, int height, bool softBorders)
    {
        var rect = new RectInt(x, y, width, height);
        var halfRect = rect.max - rect.min;
        var mapRect = new RectInt(0, 0, (int)_Map.size, (int)_Map.size);

        if (!mapRect.Contains(rect.min) || !mapRect.Contains(rect.max))
            return;

        var sborderThickness = (int)((width + height) / 2 / 5.0);
        var borderRect = new RectInt(x - sborderThickness, y - sborderThickness, width + sborderThickness * 2 - 1, height + sborderThickness * 2 - 1);

        var heightMapBak = new Dictionary<Vector2Int, float>();

        for (var px = rect.xMin; px < rect.xMax; px++)
        {
            for (var py = rect.yMin; py < rect.yMax; py++)
            {
                var point = new Vector2Int(px, py);

                if (!mapRect.Contains(point))
                    continue;

                var h = 0.5f; //TODO: configure it later on

                if (!softBorders)
                {
                    h = _Map[px, py];
                    var dist = (float)(point - rect.center).magnitude;
                    var diff = (halfRect.magnitude - dist) / halfRect.magnitude;
                    var diff_h = h - 0.5f;
                    h -= diff_h * diff;
                }

                _Map[px, py] = h;
            }
        }

        var mapBak = new Dictionary<Vector2Int, float>();
        for (var px = borderRect.xMin; px < borderRect.xMax; px++)
        {
            for (var py = borderRect.yMin; py < borderRect.yMax; py++)
            {
                var point = new Vector2Int(px, py);

                if (!mapRect.Contains(point))
                    continue;

                mapBak[point] = _Map[px, py];
            }
        }

        if (smoothConnectionBorder)
        {
            var point = new Vector2Int((int)borderRect.x, (int)borderRect.y);
            var walkLeft = (int)borderRect.width - 1;
            var dirCnt = 0;
            var dir = DIRS[dirCnt];
            var dirMod = 0;

            while (true)
            {
                if (mapRect.Contains(point))
                    SmoothPixel(point.x, point.y, mapBak);

                walkLeft -= 1;

                if (walkLeft <= 0)
                {
                    dirMod += 1;
                    dir = DIRS[dirMod % DIRS.Length];
                    walkLeft = borderRect.width - (int)(dirMod / 3) - 1;

                    if (walkLeft <= 0)
                        break;
                }

                point.x += (int)dir.x;
                point.y += (int)dir.y;
            }
        }
    }

    public void SmoothPixel(int x, int y, Dictionary<Vector2Int, float> bakMap)
    {
        var mapRect = new RectInt(0, 0, (int)_Map.size, (int)_Map.size);
        var h = 0.0f;
        var count = 0;

        for (var i = -5; i < 6; i++)
        {
            for (var k = -5; k < 6; k++)
            {
                var point = new Vector2Int(x + i, y + k);

                if (!bakMap.ContainsKey(point))
                    continue;

                h += bakMap[point];
                count += 1;
            }

        }

        if (count > 0)
            _Map[x, y] = h / count;

    }

    public void Draw()
    {
        var text = new Texture2D((int)_Map.size, (int)_Map.size);

        for (var x = 0; x < _Map.size; x++)
        {
            for (var y = 0; y < _Map.size; y++)
            {
                var height = _Map[x, y];
                var color = GetHeightColor(height);
                text.SetPixel(x, y, color);
            }
        }

        text.filterMode = FilterMode.Point;
        text.Apply();
        var sprite = Sprite.Create(text, new Rect(0, 0, _Map.size, _Map.size), Vector2.zero);
        SpriteRenderer.sprite = sprite;
        Debug.Log("Drawn!");
    }

    public Color GetHeightColor(float height)
    {
        if (!colorizeMap)
            return new Color(height, height, height);
        else if (height < 0.2f)
            return Color.blue;
        else if (height < 0.45f)
            return new Color(150.0f / 256f, 75.0f / 256f, 0); //Orange
        else if (height < 0.55f)
            return Color.yellow;
        else if (height < 0.8f)
            return Color.green;
        else if (height < 0.9f)
            return Color.gray;
        else
            return Color.white;
    }
}

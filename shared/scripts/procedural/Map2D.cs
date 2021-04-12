using System;
using Godot;

public class MapBuffer2D<T>
{
    private readonly T[] _buffer;
    private readonly int _size;

    public MapBuffer2D() { }

    public MapBuffer2D(int size)
    {
        _buffer = new T[size * size];
        _size = size;
    }

    public T this[int x, int y]
    {
        get { return _buffer[ToIndex(x, y)]; }
        set { _buffer[ToIndex(x, y)] = value; }
    }

    public T this[int i]
    {
        get { return _buffer[i]; }
        set { _buffer[i] = value; }
    }

    public T this[Vector2 pos]
    {
        get { return _buffer[ToIndex(pos)]; }
        set { _buffer[ToIndex(pos)] = value; }
    }

    public int ToIndex(Vector2 pos)
    {
        return ToIndex((int)pos.x, (int)pos.y);
    }

    public int ToIndex(int x, int y)
    {
        return x * _size + y;
    }

    public Vector2 ToPosition(int i)
    {
        return new Vector2(i / _size, i % _size);
    }

    public int BufferSize()
    {
        return _size * _size;
    }

    public int AxisSize()
    {
        return _size;
    } 

    internal T[] GetBuffer()
    {
        return _buffer;
    }
}

public class Map2D : Godot.Object
{
    public MapBuffer2D<byte> HeightMap { get; set; }

    public byte[] HeightMapBuffer { get => HeightMap.GetBuffer();}

    public Vector2[] Connections { get; set; } = new Vector2[4];

    public Vector3[] Collisions { get; set; }
}
using System;
using Godot;
using Godot.Collections;

public class ProceduralGeneratorSettings : Resource
{
    [Export]
    public int Seed { get; set; } = 0;

    [Export]
    public bool IsGenerateTerrain { get; set; } = true;

    [Export]
    public bool IsGenerateBorder { get; set; } = true;

    [Export]
    public bool IsGenerateConnections { get; set; } = true;

    [Export]
    public bool IsGenerateHeight { get; set; } = true;

    [Export]
    public int Size { get; set; } = 128;

    [Export]
    public int Octaves { get; set; } = 2;

    [Export]
    public float Persistance { get; set; } = 0.3f;

    [Export]
    public float Period { get; set; } = 20.0f;

    [Export]
    public int BorderSize { get; set; } = 30;

    [Export]
    public float BorderThickness { get; set; } = 0.05f;

    [Export]
    public bool IsBorderMountains { get; set; } = true;

    [Export]
    public int BorderConnectionSize { get; set; } = 8;

    [Export]
    public int PathNoiseRate { get; set; } = 40;

    [Export]
    public int PathThickness { get; set; } = 5;

    [Export]
    public Array<Vector2> ExistingConnections { get; set; } = new Array<Vector2> {
        Vector2.Zero,
        Vector2.Zero,
        Vector2.Zero,
        Vector2.Zero,
    };

    [Export]
    public int MapScale { get; set; } = 10;

    [Export]
    public Array<Color> HeightColors { get; set; }
}

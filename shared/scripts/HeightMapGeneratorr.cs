using Godot;
using System;


public class HeightMapGeneratorr
{
    public bool GenerateTerrain { get; set; } = true;
    public bool GenerateBorder { get; set; } = true;
    public bool GenerateConnections { get; set; } = true;
    public bool NormalizeHeight { get; set; } = true;

    public int Size { get; set; }
    public int Octaves { get; set; }
    public float Persistence { get; set; }
    public float Period { get; set; }
    public int BorderSize { get; set;}
    public float BorderThickness { get; set; }
    public bool BorderMontains { get; set; }
    public int BorderConnectionSize { get; set; }
    public int PathNoiseRate { get; set; }
    public int PathThickness { get; set; }
    
    public void test()
    {
        
    }

}

using CommonLib.Logic.Map;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Tilemaps;

[Serializable]
public class TileAtlasItem
{
    public TileType Type;
    public Tile Sprite;
}

public class TileAtlas : MonoBehaviour
{
    public TileAtlasItem[] Atlas = new TileAtlasItem[Enum.GetValues(typeof(TileType)).Length];

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public Tile GetTile(TileType tile)
    {
        return Atlas.Where(i => i.Type == tile).FirstOrDefault().Sprite;
    }
}

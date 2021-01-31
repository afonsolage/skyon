using CommonLib.Logic.Map;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Tilemaps;

namespace Assets.Scripts.Stages.Map
{
    public class TileMapRenderer : MonoBehaviour
    {
        private const int MAX_OBJ_CREATION_PER_FRAME = 30;
        private const int MAX_OBJ_DESTRUCTION_PER_FRAME = 100;

        public TileType[] TilesType { get; set; }

        public GameObject Target { get; set; }
        public int Radius { get; set; }

        private TileAtlas _atlas;

        private Dictionary<Vector2Int, GameObject> _tiles;

        private Vector2Int _lastFollowPosition;

        private Queue<Vector2Int> _destroyQueue = new Queue<Vector2Int>();
        private Queue<Vector2Int> _createQueue = new Queue<Vector2Int>();

        // Use this for initialization
        void Start()
        {
            var obj = GameObject.Instantiate(Resources.Load("prefabs/TerrainAtlas")) as GameObject;
            obj.transform.parent = transform;
            _atlas = obj.GetComponent<TileAtlas>();
            _tiles = new Dictionary<Vector2Int, GameObject>();
        }

        // Update is called once per frame
        void FixedUpdate()
        {
            var followPos = Target.gameObject.transform.position;
            var currentPos = new Vector2Int((int)followPos.x, (int)followPos.y);

            if (currentPos != _lastFollowPosition)
            {
                UpdateTileView(currentPos);
            }

            var cnt = 0;

            while (_createQueue.Count > 0 && cnt++ < MAX_OBJ_CREATION_PER_FRAME)
            {
                var p = _createQueue.Dequeue();
                CreateTile(p.x, p.y);
            }

            cnt = 0;

            while (_destroyQueue.Count > 0 && cnt++ < MAX_OBJ_DESTRUCTION_PER_FRAME)
            {
                var p = _destroyQueue.Dequeue();
                if (_tiles.TryGetValue(p, out var obj))
                {
                    GameObject.Destroy(obj);
                    _tiles.Remove(p);
                }
            }
        }

        private void UpdateTileView(Vector2Int currentPos)
        {
            var oldRect = new RectInt(_lastFollowPosition.x - Radius, _lastFollowPosition.y - Radius, Radius * 2, Radius * 2);
            _lastFollowPosition = currentPos;
            var newRect = new RectInt(_lastFollowPosition.x - Radius, _lastFollowPosition.y - Radius, Radius * 2, Radius * 2);

            var minX = Mathf.Min(oldRect.min.x, newRect.min.x);
            var maxX = Mathf.Max(oldRect.max.x, newRect.max.x);
            var minY = Mathf.Min(oldRect.min.y, newRect.min.y);
            var maxY = Mathf.Max(oldRect.max.y, newRect.max.y);

            for (var x = minX; x <= maxX; x++)
            {
                for (var y = minY; y <= maxY; y++)
                {
                    if (x < 0 || y < 0 || x >= TilesType.Length || y >= TilesType.Length)
                        continue;

                    var p = new Vector2Int(x, y);

                    if (newRect.Contains(p) && !oldRect.Contains(p) && !_createQueue.Contains(p))
                        _createQueue.Enqueue(p);
                    else if (!newRect.Contains(p) && oldRect.Contains(p) && !_destroyQueue.Contains(p))
                        _destroyQueue.Enqueue(p);

                }
            }
        }

        private void CreateTile(int x, int y)
        {
            var tileType = TilesType[x + y * 1024];
            var tile = _atlas.GetTile(tileType);

            var tileObj = new GameObject($"Tile {x},{y}");
            var renderer = tileObj.AddComponent<SpriteRenderer>();
            renderer.sprite = tile.sprite;

            tileObj.transform.Translate(new Vector3(x, y, 0));
            tileObj.transform.parent = transform;

            _tiles[new Vector2Int(x, y)] = tileObj;
        }
    }
}
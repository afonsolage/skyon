using CommonLib.GridEngine;
using CommonLib.Util.Math;
using CommonLib.Server;
using CommonLib.Util;
using System;
using System.Collections.Generic;
using ProceduralServer.Logic.Map;
using System.Drawing;
using System.Drawing.Imaging;
using System.Diagnostics;
using CommonLib.Messaging.Server;
using CommonLib.Logic.Map;

namespace ProceduralServer.Server
{
    internal partial class AppServer : GameLoopServer
    {
        #region PROCESS COMMAND
        protected override void ProcessCommand(string[] command)
        {
            base.ProcessCommand(command);

            var cmd = command[0];
            switch (cmd)
            {
                case "generate":
                    ProcessGenerate(command);
                    break;
                default:
                    CLog.W("Unkown command: {0}", cmd);
                    break;
            }
        }
        #endregion

        protected void ProcessGenerate(string[] command)
        {
            if (command.Length < 2)
            {
                CLog.W("Generate command syntax: generate <map>", command[0]);
                return;
            }

            var cmd = command[1];
            switch (cmd)
            {
                case "map":
                    ProcessGenerateMap(command);
                    break;
                default:
                    CLog.W("Unkown command: {0}", cmd);
                    break;
            }
        }

        private void ProcessGenerateMap(string[] command)
        {
            //generate map 1 1 10 2 0,21 0,3
            if (command.Length < 2)
            {
                CLog.W("Generate map command syntax: generate map <x> <y> <frequency> <ftOctaves> <ftLacunarity> <ftGain>");
                return;
            }

            var x = int.Parse(command[2]);
            var y = int.Parse(command[3]);
            var frequency = float.Parse(command[4]);
            var ftOctaves = int.Parse(command[5]);
            var ftLacunarity = float.Parse(command[6]);
            var ftGain = float.Parse(command[7]);

            var settings = new TileMapSettings
            {
                size = 1024,
                position = new Vec2(x, y),
                frequency = frequency,
                fractalOctaves = ftOctaves,
                fractalLacunarity = ftLacunarity,
                fractalGain = ftGain,

                borderSize = (int)(1024 * 0.05f),
                borderThickness = 0.05f,
                borderMontains = true,

                borderConnectionSize = (int)(1024 * 0.05f),
                surroundingConnections = new Vec2[] {new Vec2(100, 973), Vec2.INVALID, Vec2.INVALID, Vec2.INVALID}
            };

            var tileMap = MapGenerator.Generate(settings);

            var bitmap = new Bitmap(1024, 1024, PixelFormat.Format32bppRgb);
            for (var px = 0; px < 1024; px++)
            {
                for (var py = 0; py < 1024; py++)
                {
                    var tile = tileMap[px, py];
                    bitmap.SetPixel(px, py, GetTileColor(tile));
                }
            }

            bitmap.Save("output.bmp");
            new Process
            {
                StartInfo = new ProcessStartInfo(@"output.bmp")
                {
                    UseShellExecute = true,
                    WindowStyle = ProcessWindowStyle.Normal,
                }
            }.Start();

            //DBClient.Send(new PD_NFY_UPSERT_MAP()
            //{
            //    tileMap = new TileMapData()
            //    {
            //        x = 1,
            //        y = 1,
            //        heightMap = CompressionHelper.Compress(tileMap.HeightBuffer),
            //        tileType = CompressionHelper.Compress(tileMap.TileBuffer),
            //        topConnection = tileMap.Connections[0],
            //        rightConnection = tileMap.Connections[1],
            //        downConnection = tileMap.Connections[2],
            //        leftConnection = tileMap.Connections[3],
            //    }
            //});

            //var tileCompressed = CompressionHelper.Compress(tileMap.TileBuffer);
            //var uncompressedTile = tileMap.TileBuffer.Length;
            //var compressedTile = tileCompressed.Length;

            //var i = 0;
        }

        private Color GetTileColor(TileType tile)
        {
            switch (tile)
            {
                case TileType.Grass:
                    return Color.Green;
                case TileType.Rock:
                    return Color.Gray;
                case TileType.Sand:
                    return Color.Yellow;
                case TileType.Dirt:
                    return Color.Brown;
                case TileType.Snow:
                    return Color.White;
                case TileType.DeepWater:
                    return Color.DarkBlue;
                case TileType.Water:
                    return Color.Blue;
                default:
                    return Color.Black;
            }
        }
    }
}

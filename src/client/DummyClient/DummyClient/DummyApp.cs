using CommonLib.Logic.Map;
using CommonLib.Util;
using DummyClient.Networking;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Threading;

namespace DummyClient
{
    partial class DummyApp
    {
        protected bool _running;
        protected bool _closeRequested;
        protected bool _logPaused;

        public bool ViewMap { get; set; } = false;

        protected Dictionary<int, string> _pendingStatusUpdate;
        protected ConcurrentBag<Tuple<ConsoleColor, string>> _pendingLogs;

        private MapServerConnection _mapServerConnection;

        public DummyApp()
        {
            _logPaused = false;

            _closeRequested = false;
            _pendingStatusUpdate = new Dictionary<int, string>();
            _pendingLogs = new ConcurrentBag<Tuple<ConsoleColor, string>>();

            _mapServerConnection = new MapServerConnection(this, "127.0.0.1", 9876);
        }

        public virtual bool Init()
        {
            SetupLog();
            return true;
        }

        public virtual void Start()
        {
            _running = true;

            CLog.I("\t                                                ");
            CLog.I("\t██████╗░██╗░░░██╗███╗░░░███╗███╗░░░███╗██╗░░░██╗");
            CLog.I("\t██╔══██╗██║░░░██║████╗░████║████╗░████║╚██╗░██╔╝");
            CLog.I("\t██║░░██║██║░░░██║██╔████╔██║██╔████╔██║░╚████╔╝░");
            CLog.I("\t██║░░██║██║░░░██║██║╚██╔╝██║██║╚██╔╝██║░░╚██╔╝░░");
            CLog.I("\t██████╔╝╚██████╔╝██║░╚═╝░██║██║░╚═╝░██║░░░██║░░░");
            CLog.I("\t╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝░░░╚═╝░░░");
            CLog.I("");
            CLog.I("Started dummy client");

            _mapServerConnection.Start();

            StartEventLoop();
        }

        public void Quit()
        {
            if (_closeRequested)
                return;

            CLog.F("Quitting application...");

            CLog.Close();

            _closeRequested = true;
            _running = false;
        }

        protected virtual void OnClose()
        {

        }

        private void HandleLogCommand(string[] command)
        {
            if (command.Length < 2)
            {
                CLog.W("Log command: log <level>");
                return;
            }

            var cmd = command[1];

            switch (cmd)
            {
                case "level":
                    {
                        ProcessLogLevel(command);
                    }
                    break;
                case "pause":
                    {
                        CLog.W("Log generation was paused!");
                        CLog.Pause();
                    }
                    break;
                case "unpause":
                    {
                        CLog.Unpause();
                        CLog.W("Log generation was resumed!");
                    }
                    break;
                default:
                    {
                        CLog.W("Log command: log <level>");
                        return;
                    }
            }
        }

        private void ProcessLogLevel(string[] command)
        {
            if (command.Length < 3)
            {
                CLog.W("Log command: log level <debug|info|success|warn|error|fatal>");
                return;
            }

            switch (command[2])
            {
                case "debug":
                    {
                        CLog.filter = CLogType.Debug;
                    }
                    break;
                case "info":
                    {
                        CLog.filter = CLogType.Info;
                    }
                    break;
                case "success":
                    {
                        CLog.filter = CLogType.Success;
                    }
                    break;
                case "warn":
                    {
                        CLog.filter = CLogType.Warn;
                    }
                    break;
                case "error":
                    {
                        CLog.filter = CLogType.Error;
                    }
                    break;
                case "fatal":
                    {
                        CLog.filter = CLogType.Fatal;
                    }
                    break;
                default:
                    {
                        CLog.W("Log command: log level <debug|info|warn|error|fatal|success>");
                        return;
                    }
            }

            var bak = CLog.filter;
            CLog.filter = CLogType.Warn;
            CLog.W("Log level was set to {0}", command[2]);
            CLog.filter = bak;
        }



        protected virtual void SetupLog()
        {
            CLog.writter = (CLogType type, string formattedMessage) =>
            {
                ConsoleColor lineColor = ConsoleColor.Black;

                switch (type)
                {
                    case CLogType.Success:
                        lineColor = ConsoleColor.Green;
                        break;
                    case CLogType.Fatal:
                        lineColor = ConsoleColor.Magenta;
                        break;
                    case CLogType.Error:
                        lineColor = ConsoleColor.Red;
                        break;
                    case CLogType.Warn:
                        lineColor = ConsoleColor.Yellow;
                        break;
                    case CLogType.Info:
                        lineColor = ConsoleColor.Gray;
                        break;
                    case CLogType.Debug:
                        lineColor = ConsoleColor.Cyan;
                        break;
                }

                if (_logPaused)
                {
                    _pendingLogs.Add(new Tuple<ConsoleColor, string>(lineColor, formattedMessage));
                }
                else
                {
                    Console.ForegroundColor = lineColor;
                    Console.WriteLine(formattedMessage);
                }
            };
        }

        protected void StartEventLoop()
        {


            while (_running)
            {
                Thread.Sleep(10);

                if (!_pendingLogs.IsEmpty)
                {
                    while (_pendingLogs.Count > 0)
                    {
                        if (_pendingLogs.TryTake(out var tuple))
                        {
                            Console.ForegroundColor = tuple.Item1;
                            Console.WriteLine(tuple.Item2);
                        }
                        else
                        {
                            continue;
                        }
                    }
                }

                if (Console.KeyAvailable)
                {
                    var key = Console.ReadKey(true);

                    if (key.Key == ConsoleKey.Escape)
                    {
                        Quit();
                    }
                    else if (key.Key == ConsoleKey.F1)
                    {
                        _logPaused = true;
                        Console.ForegroundColor = ConsoleColor.Black;
                        Console.BackgroundColor = ConsoleColor.White;
                        Console.Write("Command: ");
                        var cmd = Console.ReadLine().Split(' ');
                        Console.ForegroundColor = ConsoleColor.White;
                        Console.BackgroundColor = ConsoleColor.Black;
                        _logPaused = false;

                        if (cmd.Length == 0)
                        {
                            continue;
                        }

                        if (cmd[0] == "log")
                        {
                            HandleLogCommand(cmd);
                        }
                        else if (cmd[0].Length > 0)
                        {
                            ProcessCommand(cmd);
                        }
                    }
                }
            }

            Environment.Exit(0);
        }

        internal void Render(TileType[] tilesType)
        {
            var bitmap = new Bitmap(1024, 1024, PixelFormat.Format32bppRgb);
            for (var px = 0; px < 1024; px++)
            {
                for (var py = 0; py < 1024; py++)
                {
                    var tile = tilesType[px + py * 1024];
                    bitmap.SetPixel(px, 1023 - py, GetTileColor(tile)); //We need to flip-y because bitmap uses Y-top-down approach
                }
            }

            bitmap.Save($"output.bmp");
            new Process
            {
                StartInfo = new ProcessStartInfo(@"output.bmp")
                {
                    UseShellExecute = true,
                    WindowStyle = ProcessWindowStyle.Normal,
                }
            }.Start();
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

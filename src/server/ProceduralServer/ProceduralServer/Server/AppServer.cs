using CommonLib.Networking;
using CommonLib.Server;
using CommonLib.Util;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Threading;
using System.Xml.Linq;

namespace ProceduralServer.Server
{
    internal partial class AppServer : GameLoopServer
    {
        private static readonly uint TICKS_PER_SECOND = 60;

        private Thread _socketThread;
        private ServerSocket<ClientSession> _socketServer;

        private DatabaseClient _dbClient;
        public DatabaseClient DBClient { get => _dbClient; }

        private readonly List<WeakReference<ClientSession>> _connectedSessions;
        private Timer _clearSessionsTimer;

        public AppServer(uint instanceId) : base(instanceId, Assembly.GetExecutingAssembly().GetName().Name, Assembly.GetExecutingAssembly().GetName().Version.ToString(), TICKS_PER_SECOND)
        {
            _connectedSessions = new List<WeakReference<ClientSession>>();
        }

        public override bool Init()
        {
            if (!base.Init())
                return false;

            CLog.I("");

            CLog.I("\t██████╗░██████╗░░█████╗░░█████╗░░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░");
            CLog.I("\t██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗");
            CLog.I("\t██████╔╝██████╔╝██║░░██║██║░░╚═╝╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝");
            CLog.I("\t██╔═══╝░██╔══██╗██║░░██║██║░░██╗░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗");
            CLog.I("\t██║░░░░░██║░░██║╚█████╔╝╚█████╔╝██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║");
            CLog.I("\t╚═╝░░░░░╚═╝░░╚═╝░╚════╝░░╚════╝░╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝");

            string welcomeMsg = string.Format("\nServer is initialized at: {0:HH:mm:ss tt}", DateTime.Now);
            CLog.I(welcomeMsg);
            CLog.I("");

            base.ShowConfigInfo();

            SetupNetworking();

            return true;
        }

        private void SetupNetworking()
        {
            string dbServerIP = GetConfig("dbServerAddress", "127.0.0.1");
            int dbServerPort = int.Parse(GetConfig("dbServerPort", "11510"));

            _dbClient = new DatabaseClient(this, dbServerIP, dbServerPort);
            _dbClient.Start();

            string listenAddr = GetConfig("listenAddress", "0.0.0.0");
            int port = int.Parse(GetConfig("listenPort", "11410"));

            _socketServer = new ServerSocket<ClientSession>(listenAddr, port);
            _socketServer.OnClientConnected += OnClientSessionConnected;
        }

        public string GetGlobalConfig(string name, string defaultValue)
        {
            return GetConfig(name, defaultValue);
        }

        protected override void OnStart()
        {
            var oneMin = TimeSpan.FromMinutes(1).Milliseconds;

            _clearSessionsTimer = new Timer(s => RemovedEmptySessionRef(), null, oneMin, oneMin);

            _socketThread = new Thread(_socketServer.Start);
            _socketThread.Start();
        }

        protected override void OnClose()
        {
            base.OnClose();

            _clearSessionsTimer?.Dispose();
            _socketServer?.Stop();
            _dbClient?.Stop();
        }

        private void OnClientSessionConnected(ClientSession session)
        {
            lock (_connectedSessions)
            {
                _connectedSessions.Add(new WeakReference<ClientSession>(session));
            }
        }

        private void RemovedEmptySessionRef()
        {
            lock (_connectedSessions)
            {
                _connectedSessions.RemoveAll((wref) => (wref.TryGetTarget(out var s)) ? !s.IsActive : true);
            }
        }

        public override void Tick(float delta)
        {
            //
        }
    }
}
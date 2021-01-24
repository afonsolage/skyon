using CommonLib.Networking;
using CommonLib.Server;
using CommonLib.Util;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Threading;
using System.Xml.Linq;

namespace RoomServer.Server
{
    internal partial class AppServer : GameLoopServer
    {
        private static readonly uint TICKS_PER_SECOND = 60;

        private Thread _socketThread;
        private ServerSocket<ClientSession> _socketServer;

        private DatabaseClient _dbClient;
        public DatabaseClient DBClient { get => _dbClient; }

        public int Capacity { get; private set; }
        public string PublicIP { get; private set; }
        public int PublicPort { get; private set; }

        private readonly List<WeakReference<ClientSession>> _connectedSessions;
        private Timer _clearSessionsTimer;
        private Timer _checkClosedSessionsTimer;

        private object _readyLock;

        public AppServer(uint instanceId) : base(instanceId, Assembly.GetExecutingAssembly().GetName().Name, Assembly.GetExecutingAssembly().GetName().Version.ToString(), TICKS_PER_SECOND)
        {
            _readyLock = new object();
            
            _connectedSessions = new List<WeakReference<ClientSession>>();
        }

        public override bool Init()
        {
            if (!base.Init())
                return false;

            CLog.I("");
            CLog.I("\t███╗░░░███╗░█████╗░██████╗░░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░");
            CLog.I("\t████╗░████║██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗");
            CLog.I("\t██╔████╔██║███████║██████╔╝╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝");
            CLog.I("\t██║╚██╔╝██║██╔══██║██╔═══╝░░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗");
            CLog.I("\t██║░╚═╝░██║██║░░██║██║░░░░░██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║");
            CLog.I("\t╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝");

            string welcomeMsg = string.Format("\nServer is initialized at: {0:HH:mm:ss tt}", DateTime.Now);
            CLog.I(welcomeMsg);
            CLog.I("");

            base.ShowConfigInfo();

            SetupNetworking();

            return true;
        }

        private void SetupNetworking()
        {
            Capacity = int.Parse(GetConfig("capacity", "1000"));
            PublicIP = GetConfig("publicAddress", "127.0.0.1");
            PublicPort = int.Parse(GetConfig("listenPort", "9876"));

            string dbServerIP = GetConfig("dbServerAddress", "127.0.0.1");
            int dbServerPort = int.Parse(GetConfig("dbServerPort", "11510"));

            _dbClient = new DatabaseClient(this, dbServerIP, dbServerPort);
            _dbClient.Start();

            string lbServerIP = GetConfig("lbServerAddress", "127.0.0.1");
            int lbServerPort = int.Parse(GetConfig("lbServerPort", "11510"));

            CLog.I("Server capacity: {0} players.", Capacity);
            CLog.I("Public IP: {0}", PublicIP);
            CLog.I("Public Port: {0}", PublicPort);
            CLog.I("Everything is ready. Publishing server....");

            PublishServer();
        }

        public string GetGlobalConfig(string name, string defaultValue)
        {
            return GetConfig(name, defaultValue);
        }

        protected override void OnStart()
        {
            var oneMin = TimeSpan.FromMinutes(1).Milliseconds;
            var oneSec = TimeSpan.FromSeconds(1).Milliseconds;

            _clearSessionsTimer = new Timer(s => RemovedEmptySessionRef(), null, oneMin, oneMin);
            _checkClosedSessionsTimer = new Timer(s => CheckClosedSessions(), null, oneSec, oneSec);
        }

        protected override void OnClose()
        {
            base.OnClose();

            _clearSessionsTimer?.Dispose();
            _checkClosedSessionsTimer?.Dispose();
            _socketServer?.Stop();
            _dbClient?.Stop();
        }

        private void PublishServer()
        {
            string listenAddr = GetConfig("listenAddress", "0.0.0.0");

            _socketServer = new ServerSocket<ClientSession>(listenAddr, PublicPort);
            _socketServer.OnClientConnected += OnClientSessionConnected;

            _socketThread = new Thread(_socketServer.Start);
            _socketThread.Start();

        }

        private void OnClientSessionConnected(ClientSession session)
        {
            session.Setup(this);

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

        private void CheckClosedSessions()
        {
            lock (_connectedSessions)
            {
                _connectedSessions.ForEach(w =>
                {
                    if (w.TryGetTarget(out var s) && !s.Connected)
                        s.Stop();
                });
            }
        }

        internal ClientSession FindSession(ulong index, string token)
        {
            WeakReference<ClientSession> wref;

            lock (_connectedSessions)
            {
                wref = _connectedSessions.Find((wr) => (wr.TryGetTarget(out var s)) ? s.DBID == index && s.Token == token && s.IsActive : false);
            }

            if (wref == null)
                return null;

            return (wref.TryGetTarget(out var session)) ? session : null;
        }

        internal ClientSession FindSessionByToken(string token)
        {
            WeakReference<ClientSession> wref;

            lock (_connectedSessions)
            {
                wref = _connectedSessions.Find((wr) => (wr.TryGetTarget(out var s)) ? s.Token == token && s.IsActive : false);
            }

            if (wref == null)
                return null;

            return (wref.TryGetTarget(out var session)) ? session : null;
        }

        public override void Tick(float delta)
        {
            //
        }
    }
}
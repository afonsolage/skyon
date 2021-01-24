using CommonLib.Networking;
using CommonLib.Server;
using CommonLib.Util;
using System;
using System.Reflection;
using System.Threading;
using System.Xml.Linq;

namespace DBServer.Server
{
    class AppServer : GameLoopServer
    {
        private static readonly uint TICKS_PER_SECOND = 60;

        private ServerSocket<ClientSession> _socketServer;
        private Thread _socketThread;

        public AppServer(uint instanceId) : base(instanceId, Assembly.GetExecutingAssembly().GetName().Name, Assembly.GetExecutingAssembly().GetName().Version.ToString(), TICKS_PER_SECOND)
        {
        }

        public override bool Init()
        {
            if (!base.Init())
                return false;

            
            CLog.I("\t██████╗░██████╗░░██████╗███████╗██████╗░██╗░░░██╗███████╗██████╗░");
            CLog.I("\t██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║░░░██║██╔════╝██╔══██╗");
            CLog.I("\t██║░░██║██████╦╝╚█████╗░█████╗░░██████╔╝╚██╗░██╔╝█████╗░░██████╔╝");
            CLog.I("\t██║░░██║██╔══██╗░╚═══██╗██╔══╝░░██╔══██╗░╚████╔╝░██╔══╝░░██╔══██╗");
            CLog.I("\t██████╔╝██████╦╝██████╔╝███████╗██║░░██║░░╚██╔╝░░███████╗██║░░██║");
            CLog.I("\t╚═════╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝");
            CLog.I("");

            string welcomeMsg = string.Format("Server is initialized at: {0:HH:mm:ss tt}", DateTime.Now);
            CLog.I(welcomeMsg);
            CLog.I("");

            base.ShowConfigInfo();

            SetupNetworking();

            return true;
        }

        protected override void OnStart()
        {
            _socketThread = new Thread(_socketServer.Start);
            _socketThread.Start();
        }

        protected override void OnClose()
        {
            base.OnClose();

            _socketServer.Stop();

            Environment.Exit(0);
        }

        private void SetupNetworking()
        {
            string listenAddr = GetConfig("listenAddress", "0.0.0.0");
            int port = int.Parse(GetConfig("listenPort", "11510"));

            _socketServer = new ServerSocket<ClientSession>(listenAddr, port);
            _socketServer.OnClientConnected += OnClientConnected;
        }

        private void OnClientConnected(ClientSession client)
        {
            client.Setup();
        }

        public override void Tick(float delta)
        {

        }
    }
}

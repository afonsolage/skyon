using System;
using CommonLib.Messaging;
using CommonLib.Messaging.Client;
using CommonLib.Messaging.Common;
using CommonLib.Networking;
using CommonLib.Util;
using MapServer.Logic;
using MapServer.Logic.Map;

namespace MapServer.Server
{
    class ClientSession : ClientConnection
    {
        private bool _authenticated;
        public bool Authenticated { get => _authenticated; set => _authenticated = value; }

        private ulong _dbid;
        public ulong DBID { get => _dbid; set => _dbid = value; }

        private string _login;
        public string Login { get => _login; set => _login = value; }

        private string _token;
        public string Token { get => _token; set => _token = value; }

        protected AppServer _app;
        public AppServer App { get => _app; }

        private MapInstance _mapInstance;

        public virtual bool RemoteDisconnection { get => !_closeRequested; }

        public void Setup(AppServer app)
        {
            _app = app;
            _authenticated = false;

            Ready();

            SendWelcomeMessage();
        }

        protected void SendWelcomeMessage()
        {
            //Send(new CR_WELCOME_NFY()
            //{
            //    serverName = _app.Name,
            //    uid = ID
            //});
        }

        public override void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);

            switch (rawMessage.MsgType)
            {
                case MessageType.CM_REQ_JOIN_MAP:
                    {
                        JoinMapInstance(rawMessage);
                    }
                    break;
                default:
                    {
                        _mapInstance.Post(this, rawMessage);
                    }
                    break;
            }
        }

        private void JoinMapInstance(RawMessage rawMsg)
        {
            var req = rawMsg.To<CM_REQ_JOIN_MAP>();
            var instance = App.MapInstanceManager.GetMapInstance(req.x, req.y, req.channel);

            if (instance == null)
            {
                CLog.E("Map instance not loaded: {0}, {1}, {2}", req.x, req.y, req.channel);
                App.MapInstanceManager.LoadMap(req.x, req.y, req.channel);
                Send(new MC_RES_JOIN_MAP() { });
                return;
            }

            _mapInstance = instance;
            instance.Post(this, rawMsg);
        }

        protected override void Close()
        {
            base.Close();
        }
    }
}

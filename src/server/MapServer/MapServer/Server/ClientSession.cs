using System;
using CommonLib.Messaging;
using CommonLib.Messaging.Common;
using CommonLib.Networking;
using CommonLib.Util;

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
                default:
                    CLog.W("Unrecognized client message type: {0}.", rawMessage.MsgType);
                    break;
            }
        }

        protected override void Close()
        {
            base.Close();
        }
    }
}

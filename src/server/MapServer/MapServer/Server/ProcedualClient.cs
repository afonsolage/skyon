using CommonLib.Messaging;
using CommonLib.Messaging.Base;
using CommonLib.Networking;
using CommonLib.Util;

namespace MapServer.Server
{
    class ProcedualClient : ClientSocket
    {
        private AppServer _app;
        public AppServer App
        {
            get
            {
                return _app;
            }
        }

        public ProcedualClient(AppServer app, string serverHost, int serverPort) : base(serverHost, serverPort)
        {
            _app = app;
        }

        public override void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);

            switch (rawMessage.MsgType)
            {
                default:
                    CLog.W("Unrecognized procedural message type: {0}.", rawMessage.MsgType);
                    break;
            }

        }
    }
}

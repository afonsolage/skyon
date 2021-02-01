using CommonLib.Messaging;
using CommonLib.Messaging.Common;
using CommonLib.Messaging.Server;
using CommonLib.Networking;
using CommonLib.Util;
using ProceduralServer.Logic.Map;

namespace ProceduralServer.Server
{
    class DatabaseClient : ClientSocket
    {
        private AppServer _app;
        public AppServer App
        {
            get
            {
                return _app;
            }
        }

        public DatabaseClient(AppServer app, string serverHost, int serverPort) : base(serverHost, serverPort)
        {
            _app = app;
        }

        public override void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);
            switch (rawMessage.MsgType)
            {
                case MessageType.DP_RES_SURROUNDING_CONNECTIONS:
                    MapHandler.ResSurroundingConnections(rawMessage.To<DP_RES_SURROUNDING_CONNECTIONS>(), this);
                    break;
                default:
                    CLog.W("Unrecognized db message type: {0}.", rawMessage.MsgType);
                    break;
            }

        }
    }
}

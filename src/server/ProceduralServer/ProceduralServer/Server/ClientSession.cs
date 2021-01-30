using CommonLib.Messaging;
using CommonLib.Messaging.Common;
using CommonLib.Messaging.Server;
using CommonLib.Networking;
using CommonLib.Util;
using ProceduralServer.Logic.Map;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProceduralServer.Server
{
    class ClientSession : ClientConnection
    {
        internal AppServer App { get; private set; }

        public override void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);
            switch (rawMessage.MsgType)
            {
                case MessageType.MP_REQ_MAP_GEN:
                    MapHandler.ReqMapGen(rawMessage.To<MP_REQ_MAP_GEN>(), this);
                    break;
                default:
                    CLog.W("Unrecognized message type: {0}.", rawMessage.MsgType);
                    break;
            }

        }

        internal void Setup(AppServer app)
        {
            App = app;
            Ready();
        }
    }
}

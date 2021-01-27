using CommonLib.Messaging;
using CommonLib.Messaging.Common;
using CommonLib.Messaging.Server;
using CommonLib.Networking;
using CommonLib.Util;
using DBServer.Query;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DBServer.Server
{
    class ClientSession : ClientConnection
    {
        public override void Handle(Packet packet)
        {
            var rawMessage = new RawMessage(packet.buffer);
            switch (rawMessage.MsgType)
            {
                case MessageType.PB_NFY_UPSERT_MAP:
                    ProceduralServer.NfyUpsertMap(rawMessage.To<PB_NFY_UPSERT_MAP>(), this);
                    break;
                default:
                    CLog.W("Unrecognized message type: {0}.", rawMessage.MsgType);
                    break;
            }

        }

        internal void Setup()
        {
            Ready();
        }
    }
}

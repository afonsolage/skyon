using CommonLib.Messaging;
using CommonLib.Messaging.Base;
using CommonLib.Networking;
using CommonLib.Util;
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

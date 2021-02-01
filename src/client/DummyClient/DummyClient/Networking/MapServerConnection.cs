using CommonLib.Logic.Map;
using CommonLib.Messaging.Client;
using CommonLib.Messaging.Common;
using CommonLib.Networking;
using CommonLib.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DummyClient.Networking
{

    class MapServerConnection : ClientSocket
    {
        internal DummyApp App { get; private set; }
        public MapServerConnection(DummyApp app, string serverHost, int serverPort) : base(serverHost, serverPort) { App = app; }

        public override void Handle(Packet packet)
        {
            var rawMsg = new RawMessage(packet.buffer);
            switch(rawMsg.MsgType)
            {
                case MessageType.MC_RES_JOIN_MAP:
                    JoinMapResult(rawMsg.To<MC_RES_JOIN_MAP>());
                    break;
                default:
                    CLog.W("Unkown message type: {0}", rawMsg.MsgType);
                    break;
            }
        }

        private void JoinMapResult(MC_RES_JOIN_MAP res)
        {
            if (res.tileMap == null)
            {
                CLog.I("Map wasn't loaded. Try again now.");
                return;
            }
            else
            {
                var tilesType = CompressionHelper.Decompress(res.tileMap.tileType).Cast<TileType>().ToArray();
                CLog.I("Received map size: {0}", tilesType.Length);

                if (App.ViewMap)
                {
                    App.Render(tilesType);
                }
            }
        }
    }
}

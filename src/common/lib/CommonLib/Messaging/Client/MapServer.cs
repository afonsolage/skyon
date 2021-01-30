using CommonLib.Messaging.Common;
using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Messaging.Client
{
    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class CM_REQ_JOIN_MAP : IMessage
    {
        public CM_REQ_JOIN_MAP() { MsgType = MessageType.CM_REQ_JOIN_MAP; }
        public MessageType MsgType { get; }

        public int x;
        public int y;
        public int channel;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class MC_RES_JOIN_MAP : IMessage
    {
        public MC_RES_JOIN_MAP() { MsgType = MessageType.MC_RES_JOIN_MAP; }
        public MessageType MsgType { get; }

        public TileMapSimple tileMap;
    }
}

#if _SERVER
using CommonLib.Messaging;
using CommonLib.Messaging.Common;
using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Messaging.Server
{
    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class MP_REQ_MAP_GEN : IMessage
    {
        public MP_REQ_MAP_GEN() { MsgType = MessageType.MP_REQ_MAP_GEN; }
        public MessageType MsgType { get; }
        public int x;
        public int y;
        public int channel;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class PM_RES_MAP_GEN : IMessage
    {
        public PM_RES_MAP_GEN() { MsgType = MessageType.PM_RES_MAP_GEN; }
        public MessageType MsgType { get; }
        public int x;
        public int y;
        public int channel;
    }
}
#endif
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
    public class PB_NFY_UPSERT_MAP : IMessage
    {
        public PB_NFY_UPSERT_MAP() { MsgType = MessageType.PB_NFY_UPSERT_MAP; }
        public MessageType MsgType { get; }

        public TileMap tileMap;

    }
}

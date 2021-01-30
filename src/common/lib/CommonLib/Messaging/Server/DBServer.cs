#if _SERVER
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

        public TileMapData tileMap;

    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class MD_REQ_MAP_INFO : IMessage
    {
        public MD_REQ_MAP_INFO() { MsgType = MessageType.MD_REQ_MAP_INFO; }
        public MessageType MsgType { get; }

        public int x;
        public int y;
        public ushort channel;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class DM_RES_MAP_INFO : IMessage
    {
        public DM_RES_MAP_INFO() { MsgType = MessageType.DM_RES_MAP_INFO; }
        public MessageType MsgType { get; }

        public TileMapData tileMap;
        public ushort channel;
    }
}
#endif

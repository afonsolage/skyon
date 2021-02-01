#if _SERVER
using CommonLib.Messaging.Common;
using CommonLib.Util.Math;
using ProtoBuf;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Messaging.Server
{
    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class PD_NFY_UPSERT_MAP : IMessage
    {
        public PD_NFY_UPSERT_MAP() { MsgType = MessageType.PD_NFY_UPSERT_MAP; }
        public MessageType MsgType { get; }

        public TileMapData tileMap;

    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class PD_REQ_SURROUNDING_CONNECTIONS : IMessage
    {
        public PD_REQ_SURROUNDING_CONNECTIONS() { MsgType = MessageType.PD_REQ_SURROUNDING_CONNECTIONS; }
        public MessageType MsgType { get; }

        public int x;
        public int y;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class DP_RES_SURROUNDING_CONNECTIONS : IMessage
    {
        public DP_RES_SURROUNDING_CONNECTIONS() { MsgType = MessageType.DP_RES_SURROUNDING_CONNECTIONS; }
        public MessageType MsgType { get; }

        public int x;
        public int y;
        public Vec2 top_connection;
        public Vec2 left_connection;
        public Vec2 down_connection;
        public Vec2 right_connection;
        public bool has_top_connection;
        public bool has_left_connection;
        public bool has_down_connection;
        public bool has_right_connection;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class MD_REQ_MAP_INFO : IMessage
    {
        public MD_REQ_MAP_INFO() { MsgType = MessageType.MD_REQ_MAP_INFO; }
        public MessageType MsgType { get; }

        public int x;
        public int y;
    }

    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class DM_RES_MAP_INFO : IMessage
    {
        public DM_RES_MAP_INFO() { MsgType = MessageType.DM_RES_MAP_INFO; }
        public MessageType MsgType { get; }

        public TileMapData tileMap;
    }
}
#endif

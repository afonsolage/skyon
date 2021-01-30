using ProtoBuf;

namespace CommonLib.Messaging.Client
{
    [ProtoContract(ImplicitFields = ImplicitFields.AllPublic)]
    public class TileMapSimple
    {
        public byte[] tileType;
    }
}

using CommonLib.Networking;
using CommonLib.Util;
using CommonLib.Messaging.Common;
using CommonLib.Messaging.Client;
using System;
using System.Linq;
using CommonLib.Logic.Map;

public class RoomServerConnection : ServerConnection
{
    public MapStage Stage
    {
        get { return (MapStage)_stage; }
    }

    public RoomServerConnection(MapStage stage, string serverHost, int serverPort) : base(stage, serverHost, serverPort)
    {
    }

    public override void HandleOnMainThread(Packet packet)
    {
        var rawMessage = new RawMessage(packet.buffer);

        switch (rawMessage.MsgType)
        {
            case MessageType.MC_RES_JOIN_MAP:
                {
                    ResultJoinMap(rawMessage.To<MC_RES_JOIN_MAP>());
                }
                break;
            default:
                CLog.W("Unrecognized message type: {0}.", rawMessage.MsgType);
                break;
        }
    }

    private void ResultJoinMap(MC_RES_JOIN_MAP res)
    {
        if (res.tileMap == null)
        {
            CLog.I("Map wasn't loaded yet, asking again.");
            StageManager.GetCurrent<MapStage>()?.RequestJoinMap();
            return;
        }
        var tilesType = CompressionHelper.Decompress(res.tileMap.tileType).Cast<TileType>().ToArray();

        StageManager.GetCurrent<MapStage>()?.SetTilesType(tilesType);
    }
}

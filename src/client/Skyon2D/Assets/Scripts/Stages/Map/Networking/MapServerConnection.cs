using System;
using CommonLib.Messaging.Base;
using CommonLib.Networking;
using CommonLib.Util;
using CommonLib.Messaging.Client;
using CommonLib.Messaging;

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
            default:
                CLog.W("Unrecognized message type: {0}.", rawMessage.MsgType);
                break;
        }
    }
}

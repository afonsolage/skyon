using CommonLib.Util;
using UnityEngine;
using CommonLib.Messaging.Client;

public class MapStage : BaseStage
{
    public int latency = 0;

    public CLogType logLevel = CLogType.Debug;

    public RoomServerConnection ServerConnection
    {
        get
        {
            return (RoomServerConnection)_connection;
        }
    }

    private uint _sessionID;
    public uint SessionID
    {
        get
        {
            return _sessionID;
        }
        set
        {
            _sessionID = value;
        }
    }

    public override void OnTick(float delta) { }

    protected override void ProcessMessage(string message)
    {
        switch (message)
        {
            case "FinishRoomState":
                break;
            case "Started":
                break;
            case "Connected":
                Start();
                break;
            case "Disconnected":
                break;
            case "Reconnected":
                break;
            default:
                CLog.W("Unknown message received: {0}", message);
                break;
        }
    }

    private void Start()
    {
        ServerConnection.Send(new CX_TOKEN_REQ()
        {
            token = "teste token!",
        });
    }

    public override void OnDispose()
    {
        _connection?.Stop();
    }

    public override void Init(params object[] args)
    {
        var serverIp = args[0] as string;
        var port = int.Parse(args[1].ToString());

        _connection = new RoomServerConnection(this, serverIp, port)
        {
#if _DEBUG
            LatencySimulation = (uint)latency
#endif
        };
        _connection.Start();
    }
}

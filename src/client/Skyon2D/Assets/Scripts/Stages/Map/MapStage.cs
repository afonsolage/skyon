using CommonLib.Util;
using UnityEngine;
using CommonLib.Messaging.Client;
using Assets.Scripts.Stages.Map;
using CommonLib.Logic.Map;
using UnityEngine.Tilemaps;

public class MapStage : BaseStage
{
    public int X { get; set; }
    public int Y { get; set; }
    public int Channel { get; set; }


    public int latency = 0;
    public CLogType logLevel = CLogType.Debug;

    public TileMapRenderer TileMapRenderer { get; private set; }

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

    internal void SetTilesType(TileType[] tilesType)
    {
        TileMapRenderer.TilesType = tilesType;
        TileMapRenderer.enabled = true;
    }

    private void Start()
    {

    }

    public override void OnDispose()
    {
        _connection?.Stop();
    }

    public override void Init(params object[] args)
    {
        var serverIp = args[0] as string;
        var port = int.Parse(args[1].ToString());

        X = int.Parse(args[2].ToString());
        Y = int.Parse(args[3].ToString());
        Channel = int.Parse(args[4].ToString());

        _connection = new RoomServerConnection(this, serverIp, port)
        {
#if _DEBUG
            LatencySimulation = (uint)latency
#endif
        };
        _connection.Start();
        RequestJoinMap();

        var tileMapObj = new GameObject();
        tileMapObj.transform.parent = Main.Current.transform;

        TileMapRenderer = tileMapObj.AddComponent<TileMapRenderer>();
        TileMapRenderer.Radius = 25;
        TileMapRenderer.Target = GameObject.Find("MainPlayer");
        TileMapRenderer.enabled = false;

        tileMapObj.name = $"TileMap {X},{Y}[{Channel}]";
    }

    public void RequestJoinMap()
    {
        _connection.Send(new CM_REQ_JOIN_MAP()
        {
            x = X,
            y = Y,
            channel = Channel,
        });
    }
}

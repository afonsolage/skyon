using CommonLib.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

public class Main : MonoBehaviour
{
    private static Main _current = null;
    public static Main Current
    {
        get { return _current; }
    }

    public uint logLevel = 0;

    private int _fps = 60;
    public int FPS
    {
        get { return _fps; }
        set { _fps = value; }
    }

    protected void Awake()
    {
        _current = this;

        SetupLogWritter();
    }

    protected void Start()
    {
        try
        {
            FPS = Application.targetFrameRate;

            // Init components of the client.
            Initialization();

            // Set Loading Stage, where will to load resources and check if has some update pending.
            StageManager.ChangeStage(StageType.MapStage, "127.0.0.1", "9876", 15, 15, 0);
        }
        catch (Exception e)
        {
            CLog.E("Failed to start application. Catching error...");
            CLog.Catch(e);
        }
    }

    protected void Update()
    {
        StageManager.Tick(Time.deltaTime);
    }

    protected void FixedUpdate()
    {
        StageManager.FixedTick(Time.fixedDeltaTime);
    }

    protected void OnDestroy()
    {
        StageManager.Shutdown();
    }

    private void Initialization()
    {
    }

    private void SetupLogWritter()
    {
        CLog.LogPath = Application.persistentDataPath;
#if UNITY_EDITOR
        CLog.filter = CLogType.Debug;
        CLog.EnableLogOnFile = true;
#else
        CLog.filter = CLogType.Debug;
        CLog.EnableLogOnFile = true;
#endif

        CLog.writter = (CLogType type, string msg) =>
        {
            if ((int)type < (int)logLevel)
                return;

            switch (type)
            {
                case CLogType.Debug:
                    Debug.Log(msg);
                    break;
                case CLogType.Error:
                    Debug.LogError(msg);
                    break;
                case CLogType.Fatal:
                    Debug.LogError(msg);
                    break;
                case CLogType.Info:
                    Debug.Log(msg);
                    break;
                case CLogType.Warn:
                    Debug.LogWarning(msg);
                    break;
                default:
                    Debug.LogError("[UNKNOWN] " + msg);
                    break;
            }
        };

        CLog.I("Logging Enabled! Level: {0}", CLog.filter);
    }
}

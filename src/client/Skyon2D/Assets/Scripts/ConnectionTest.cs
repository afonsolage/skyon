using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConnectionTest : MonoBehaviour
{
    public void OnTestClick()
    {
        StageManager.ChangeStage(StageType.MapStage, "127.0.0.1", "9876");
    }
}

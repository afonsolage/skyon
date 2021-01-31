using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{

    public float MoveSpeed = 10f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var moveHorizontal = Input.GetAxis("Horizontal") * MoveSpeed * Time.deltaTime;
        var moveVertical = Input.GetAxis("Vertical") * MoveSpeed * Time.deltaTime;

        transform.Translate(new Vector3(moveHorizontal, moveVertical, 0));
    }
}

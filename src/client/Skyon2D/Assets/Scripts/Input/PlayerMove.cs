using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{

    public float MoveSpeed = 10f;
    private Animator _animator;

    // Start is called before the first frame update
    void Start()
    {
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        var move = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0);
        var moveDir = move * MoveSpeed * Time.deltaTime;
        var mag = moveDir.magnitude;

        _animator.SetFloat("Magnitude", mag);

        if (mag > 0.001)
        {
            _animator.SetFloat("Horizontal", move.x);
            _animator.SetFloat("Vertical", move.y);
            transform.Translate(moveDir);
        }
    }

}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Lighning : MonoBehaviour
{
    Camera mainCamera;

    public bool alignVertical = false;

    public Vector3 eulerAngles = Vector3.zero;

    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        if (mainCamera == null)
            mainCamera = Camera.main;

        Vector3 _targetDirection = transform.position - mainCamera.transform.position;
        Quaternion currentRotation = transform.rotation;
        Quaternion targetRotation = Quaternion.LookRotation(_targetDirection, eulerAngles);

        transform.rotation = targetRotation;
    }
}

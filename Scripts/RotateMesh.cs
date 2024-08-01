using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateMesh : MonoBehaviour
{
    // speed of rotation
    public float rotationSpeed = 30f;

   void Update()
{
    float rotationAmount = rotationSpeed * Time.deltaTime;

    // Z axis rotation
    transform.Rotate(0, 0, rotationAmount);

}

}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WindowDissolving : MonoBehaviour
{
    public Material windowMaterial; // Material of the window
    private float burnSpeed = 0.1f; // Speed at which the paper burns
    private bool isBurning = false; // Whether the paper is currently burning

    public static float burned;

    // Start is called before the first frame update
    void Start()
    {
        windowMaterial.SetFloat("_Glossiness", -0.1f);
    }

    // Update is called once per frame
    void Update()
    {
        // If the H key is pressed, start burning the paper
        if (Input.GetKeyDown(KeyCode.H))
        {
            isBurning = true;
        }

        // If the paper is burning, increase the _Glossiness property of the material
        if (isBurning)
        {
            burned = windowMaterial.GetFloat("_Glossiness");
            burned += burnSpeed * Time.deltaTime; 
            windowMaterial.SetFloat("_Glossiness", burned);
        }
    }
}

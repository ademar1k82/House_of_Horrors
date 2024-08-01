using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BurningPaper : MonoBehaviour
{
    public Material paperMaterial; // Material of the paper
    private bool isBurning = false; // Whether the paper is currently burning

    void Start()
    {
        paperMaterial.SetFloat("_Glossiness", -0.1f);
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
            float glossiness = WindowDissolving.burned;
            paperMaterial.SetFloat("_Glossiness", glossiness);
        }
    }
}

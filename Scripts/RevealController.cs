using UnityEngine;

public class RevealController : MonoBehaviour
{
    public Material material;  // O material que usa o shader
    public float revealSpeed = 1.0f;  // Velocidade de revelação
    public float minVal = -1.0f;  // Valor mínimo de _Val
    public float maxVal = 1.0f;   // Valor máximo de _Val

    private float currentVal;
    private bool opening = true;

    void Start()
    {
        if (material == null)
        {
            Debug.LogError("Material não atribuído!");
            enabled = false;
            return;
        }
        currentVal = minVal;
        material.SetFloat("_Val", currentVal);
    }

    void Update()
    {
        if (opening)
        {
            currentVal += revealSpeed * Time.deltaTime;
            if (currentVal >= maxVal)
            {
                currentVal = maxVal;
                opening = false;
            }
        }
        else
        {
            currentVal -= revealSpeed * Time.deltaTime;
            if (currentVal <= minVal)
            {
                currentVal = minVal;
                opening = true;
            }
        }

        material.SetFloat("_Val", currentVal);
    }
}

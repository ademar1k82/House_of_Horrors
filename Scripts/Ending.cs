using System.Collections;
using UnityEngine;

public class Ending : MonoBehaviour
{
    public Material mat;
    private float _radius = 1.0f; // Initial radius value
    private bool isClosing = false; // Flag to check if the closing effect is happening
    public float animationDuration = 3.0f; // Duration for the closing effect, can be set in Unity inspector
    public GameObject lastCanvas;

    void Start()
    {
        // Set initial shader properties
        mat.SetFloat("_Radius", _radius);
        mat.SetFloat("_CenterX", 0.25f);
        mat.SetFloat("_CenterY", 0.25f);
    }

    void Update()
    {
        // Check if 'E' key is pressed
        if (Input.GetKeyDown(KeyCode.E) && !isClosing)
        {
            StartCoroutine(ClosingScene());
            if(lastCanvas != null && lastCanvas.activeSelf)
            {
                lastCanvas.SetActive(false);
            }
            
        }
    }

    IEnumerator ClosingScene()
    {
        isClosing = true;
        float startTime = Time.time;

        while (_radius > 0)
        {
            // Calculate elapsed time
            float elapsedTime = Time.time - startTime;

            // Calculate new radius value
            _radius = Mathf.Lerp(1.0f, 0.0f, elapsedTime / animationDuration);

            // Update shader radius property
            mat.SetFloat("_Radius", _radius);

            yield return null;

            // Break the loop if the duration has passed
            if (elapsedTime >= animationDuration)
            {
                break;
            }
        }

        _radius = 0.0f; // Ensure radius is set to 0
        isClosing = false;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // Read pixels from the source RenderTexture, apply the material, copy the updated results to the destination RenderTexture
        Graphics.Blit(src, dest, mat);
    }
}
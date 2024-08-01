using UnityEngine;

// This script requires a Camera component to be attached to the same GameObject
[RequireComponent(typeof(Camera))]
public class NightVisionController : MonoBehaviour
{
    // Public variable to assign the NightVision Material in the Inspector
    public Material NightVisionMaterial;

    // Public variable to control the transition speed of the NightVision effect
    public float TransitionSpeed = 1.0f;
    // Private variables to control the NightVision effect
    private bool isNightVisionOn = false;
    private float transitionFactor = 0.0f;

    // Start is called before the first frame update
    private void Start()
    {
        // Initialize NightVision as off and transition factor as 1.0f
        isNightVisionOn = false;
        transitionFactor = 1.0f;

        // Set the initial values of the shader properties
        NightVisionMaterial.SetInt("_IsNightVisionOn", isNightVisionOn ? 1 : 0);
        NightVisionMaterial.SetFloat("_TransitionFactor", transitionFactor);
    }

    // Update is called once per frame
    private void Update()
    {
        // Toggle NightVision on/off when the 'O' key is pressed
        if (Input.GetKeyDown(KeyCode.O))
        {
            isNightVisionOn = !isNightVisionOn;
            NightVisionMaterial.SetInt("_IsNightVisionOn", isNightVisionOn ? 1 : 0);
        }

        // Update the transition factor based on whether NightVision is on or off
        if (isNightVisionOn)
        {
            transitionFactor = Mathf.Clamp01(transitionFactor - Time.deltaTime * TransitionSpeed);
        }
        else
        {
            transitionFactor = Mathf.Clamp01(transitionFactor + Time.deltaTime * TransitionSpeed);
        }

        // Update the shader property with the new transition factor
        NightVisionMaterial.SetFloat("_TransitionFactor", transitionFactor);
    }

    // Called after all rendering is complete to render image
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // If the NightVision Material is assigned, use it to render the image
        if (NightVisionMaterial != null)
        {
            Graphics.Blit(source, destination, NightVisionMaterial);
        }
        // Otherwise, render the image without any effect
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
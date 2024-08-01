using UnityEngine;

public class GlitchCamera : MonoBehaviour
{
    // Material to be used for the glitch effect
    public Material material;

    [Header("Glitch Settings")]
    public float glitchTime = 5.0f; // Total duration of the glitch effect
    public float maxOffsetVariation = 0.2f; // Maximum variation in color offset
    public float blurAmount = 0.0f; // Amount of blur

    private bool isGlitchActive = false; // Flag to check if glitch effect is active
    private float glitchTimer = 0.0f; // Timer to control the glitch effect

    // Initial color offsets
    private Vector2 redOffset = Vector2.zero;
    private Vector2 greenOffset = Vector2.zero;
    private Vector2 blueOffset = Vector2.zero;

    void Start()
    {
        // Check if the material is assigned
        if (material == null)
        {
            Debug.LogError("Material is not assigned!");
        }
    }

    void Update()
    {
        // Check if the space bar is pressed to start the glitch effect
        if (Input.GetKeyDown(KeyCode.Space) && !isGlitchActive)
        {
            isGlitchActive = true;
            glitchTimer = glitchTime;
        }

        // If the glitch effect is active
        if (isGlitchActive)
        {
            // If the glitch timer is not expired
            if (glitchTimer > 0)
            {
                UpdateGlitchEffect();
            }
            else
            {
                EndGlitchEffect();
            }
        }
    }

    // Method to update the glitch effect
    private void UpdateGlitchEffect()
    {
        // Update the glitch timer
        glitchTimer -= Time.deltaTime;
        float t = glitchTimer / glitchTime;
        float smoothT = Mathf.Sin(t * Mathf.PI);

        // Generate random values for color offsets
        redOffset = GenerateRandomOffset(smoothT);
        greenOffset = GenerateRandomOffset(smoothT);
        blueOffset = GenerateRandomOffset(smoothT);

        // Update the material properties
        if (material != null)
        {
            UpdateMaterialProperties();
        }
        else
        {
            Debug.LogError("Material is not assigned!");
        }
    }

    // Method to generate a random offset
    private Vector2 GenerateRandomOffset(float smoothT)
    {
        return new Vector2(Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT, Random.Range(-maxOffsetVariation, maxOffsetVariation) * smoothT);
    }

    // Method to update the material properties
    private void UpdateMaterialProperties()
    {
        material.SetFloat("_RedX", redOffset.x);
        material.SetFloat("_RedY", redOffset.y);
        material.SetFloat("_GreenX", greenOffset.x);
        material.SetFloat("_GreenY", greenOffset.y);
        material.SetFloat("_BlueX", blueOffset.x);
        material.SetFloat("_BlueY", blueOffset.y);
        material.SetFloat("_BlurAmount", blurAmount);
    }

    // Method to end the glitch effect
    private void EndGlitchEffect()
    {
        // End the glitch effect
        isGlitchActive = false;

        // Reset the material properties if desired
        if (material != null)
        {
            ResetMaterialProperties();
        }
        else
        {
            Debug.LogError("Material is not assigned!");
        }
    }

    // Method to reset the material properties
    private void ResetMaterialProperties()
    {
        material.SetFloat("_RedX", 0.0f);
        material.SetFloat("_RedY", 0.0f);
        material.SetFloat("_GreenX", 0.0f);
        material.SetFloat("_GreenY", 0.0f);
        material.SetFloat("_BlueX", 0.0f);
        material.SetFloat("_BlueY", 0.0f);
        material.SetFloat("_BlurAmount", 0.0f);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // If the material is assigned, apply it to the source texture and output to the destination texture
        if (material != null)
        {
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Debug.LogError("Material is not assigned in OnRenderImage!");
            Graphics.Blit(source, destination);
        }
    }
}
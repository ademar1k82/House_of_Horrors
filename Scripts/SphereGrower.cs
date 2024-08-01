using UnityEngine;

public class SphereGrower : MonoBehaviour
{
    public Material growMaterial; // Material to be used when the sphere is growing
    private Material originalMaterial; // Original material of the sphere
    private Renderer sphereRenderer; // Renderer of the sphere
    private Vector3 originalScale; // Original scale of the sphere
    private Vector3 targetScale; // Target scale of the sphere

    private bool isGrowing = false; // Flag to check if the sphere is growing
    public float growDuration = 1.0f; // Duration of the growth
    public long growIterations = 1; // Number of growth iterations
    private long currentIteration = 0; // Current iteration
    private float growTimer = 0.0f; // Timer to control the growth

    void Start()
    {
        // Get the renderer of the sphere and save the original material and scale
        sphereRenderer = GetComponent<Renderer>();
        originalMaterial = sphereRenderer.material;
        originalScale = transform.localScale;
        targetScale = originalScale * 20.0f; // Set the target scale
    }

    void Update()
    {
        // Check if the 'S' key is pressed and if the current iteration is less than the total iterations
        if (Input.GetKeyDown(KeyCode.S) && currentIteration < growIterations)
        {
            StartGrowing();
        }

        // If the sphere is growing
        if (isGrowing)
        {
            UpdateGrowing();
        }
    }

    // Method to start the growth of the sphere
    private void StartGrowing()
    {
        currentIteration++;
        isGrowing = true;
        growTimer = 0.0f;
        sphereRenderer.material = growMaterial; // Change the material of the sphere
    }

    // Method to update the growth of the sphere
    private void UpdateGrowing()
    {
        growTimer += Time.deltaTime;

        float t = growTimer / growDuration;
        t = Mathf.Clamp01(t); // Clamp the value of 't' between 0 and 1

        // Interpolate the scale of the sphere from the original scale to the target scale
        transform.localScale = Vector3.Lerp(originalScale, targetScale, t);

        // If the sphere has reached the target scale
        if (t >= 1.0f)
        {
            isGrowing = false;
        }
    }
}

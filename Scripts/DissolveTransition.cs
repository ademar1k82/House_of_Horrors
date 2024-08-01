using UnityEngine;

public class MaterialChange : MonoBehaviour
{
    public Material newMaterial;
    public float changeDelay = 2.0f;
    private bool isChanging = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T) && !isChanging)
        {
            isChanging = true;
            Invoke("ChangeMaterial", changeDelay);
        }
    }

    void ChangeMaterial()
    {
        Renderer rend = GetComponent<Renderer>();
        rend.material = newMaterial;
        isChanging = false;
    }
}

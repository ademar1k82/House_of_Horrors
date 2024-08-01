using UnityEngine;
using Cinemachine;

public class CameraSwitcher : MonoBehaviour
{
    public CinemachineFreeLook[] cameras;
    public Canvas[] canvases;
    private int currentCameraIndex = 0;

    void Start()
    {
        SwitchCamera(0);
    }

    public void SwitchCamera(int cameraIndex)
    {
        if (cameraIndex < 0 || cameraIndex >= cameras.Length)
            return;

        for (int i = 0; i < cameras.Length; i++)
        {
            cameras[i].Priority = (i == cameraIndex) ? 10 : 0;
            canvases[i].gameObject.SetActive(i == cameraIndex);
        }
        currentCameraIndex = cameraIndex;
    }

    public void NextCamera()
    {
        int nextIndex = (currentCameraIndex + 1) % cameras.Length;
        SwitchCamera(nextIndex);
    }

    public void PreviousCamera()
    {
        int prevIndex = (currentCameraIndex - 1 + cameras.Length) % cameras.Length;
        SwitchCamera(prevIndex);
    }
}


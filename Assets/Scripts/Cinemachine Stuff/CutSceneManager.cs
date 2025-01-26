using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;

public class CutSceneManager : MonoBehaviour
{
    [Header("Managers")]
    [SerializeField] EncounterManager encounterManager; // To Eploration
    [SerializeField] PlayerInteractor playerInteractor; // To Arena
    [SerializeField] UIManager uiManager; 

    [Header("Cinemachine Cameras")]
    [SerializeField] CinemachineCamera mainCamera;
    [SerializeField] CinemachineCamera arenaCameraNeeded;
    [SerializeField] CinemachineCamera roomCameraNeeded;

    [Header("Refrences")]
    [SerializeField] PlayableDirector exitFromRoom;
    [SerializeField] PlayableDirector exitFromArena;

    [Header("Fading Data")]
    [SerializeField] Image fadeImage;
    [SerializeField] float fadeDuration = 1.0f;
    [SerializeField] float fadeInDuration = 1.5f;


    [Header("Interactables Objects")]
    [SerializeField] bool isRoomScene = true;
    private Transform _currentCollectedObject;
    private Transform _lastCollectedObject;
    private Scene _currentScene;

   

    private void Start()
    {
        _currentScene = SceneManager.GetActiveScene();

        SetPlayerInteractCutSceneManager();
        HandleCameraPositions();
        StartCoroutine(HandlePriority());
        SetFadeWhenStartScene();

        if (encounterManager != null)
            encounterManager.AllEnemisDied += PlayExitArena;
        if (uiManager.EncounterPrompt != null)
            uiManager.EncounterPrompt.OnSelect += HandleTrastions;

    }
    private void HandleCameraPositions()
    {
        if (isRoomScene)
        {
            if (_lastCollectedObject == null)
            {
                // Retrieve the saved position
                Vector3 savedPosition = GameManager.Instance.GetLastObjectPosition();  // Assuming it returns Vector3

                // Ensure the saved position is valid (not Vector3.zero)
                if (savedPosition != Vector3.zero)
                {
                    // Instantiate or move an object to the saved position
                    _lastCollectedObject = new GameObject("LastCollectedObject").transform;
                    _lastCollectedObject.position = savedPosition;

                    Debug.Log($"Going to the last saved position: {savedPosition}");
                    ChangeCameraPosition(arenaCameraNeeded, _lastCollectedObject);
                }
                else
                {
                    ChangeCameraPosition(arenaCameraNeeded, arenaCameraNeeded.transform);
                }
            }
            else
            {
                // Move the camera to the existing object's position
                ChangeCameraPosition(arenaCameraNeeded, _lastCollectedObject);
                Debug.Log("_lastCollectedObject already exists.");
            }
        }
        else  // If not a room scene
        {
            ChangeCameraPosition(arenaCameraNeeded, arenaCameraNeeded.transform);
        }
    }

    private void SetPlayerInteractCutSceneManager()
    {
        if (playerInteractor == null) return;

        Debug.Log("Setted cut scene");
        playerInteractor.CutSceneManager = this; // Set the cutceene to the player interact
    }
    private void SaveLastObjectCollected(Transform lastTransform)
    {
        _lastCollectedObject = _currentCollectedObject;
        GameManager.Instance.SaveLastObjectCollected(lastTransform);
        Debug.Log($"Pos Saved {lastTransform.position}");
    }
    #region << Handle Cut Scene>>
    public void TryChangeCollectedObject(Transform objectTrans)
    {
        _currentCollectedObject = objectTrans;
        ChangeCameraPosition(roomCameraNeeded, _currentCollectedObject);

        // Save 
        SaveLastObjectCollected(_currentCollectedObject);
    }
    private void PlayExitArena()
    {
        StartCutscene(exitFromArena, 0);
        exitFromArena.Play();

    }
    private void PlayExitRoom()
    {
        StartCutscene(exitFromRoom, 1);
        exitFromRoom.Play();
    }
    private void ChangeCameraPosition(CinemachineCamera localCamera ,Transform wantedTransform)
    {
        localCamera.transform.position = wantedTransform.position;
        localCamera.transform.rotation = wantedTransform.rotation;
    }
    private void GetEncounter(EncounterPrompt encounterPrompt)
    {
        encounterPrompt.OnSelect += HandleTrastions;
    }

    private void HandleTrastions(bool confirm)
    {
        if (confirm)
        {
            //GameManager.Instance.backgroundMusicController.PlayCombatBackgroundMusic();
            PlayExitRoom();
        }
        else
        {
            PlayExitArena();
        }

    }

    #endregion
    private void StartCutscene(PlayableDirector timeline, int sceneIndex)
    {

        timeline.stopped -= TimeLineFinished;
        timeline.stopped += TimeLineFinished;

        StartCoroutine(PlayTimeline(timeline));
    }

    private void TimeLineFinished(PlayableDirector pd)
    {
        OnTimelineFinished(_currentScene.buildIndex);

    }
    private IEnumerator PlayTimeline(PlayableDirector timeline)
    {
        float timelineDuration = (float)timeline.duration;  // Get the timeline duration

        timeline.Play();  // Start playing the timeline

        // Start fading to alpha = 1 over the entire timeline duration
        yield return StartCoroutine(FadeCanvas(1, timelineDuration));

        Debug.Log("Timeline and fade completed");
    }
    private IEnumerator HandlePriority()
    {
        mainCamera.Priority = 10;
        arenaCameraNeeded.Priority = 20;
        yield return new WaitForSeconds(fadeInDuration / 2);

        mainCamera.Priority = 20;
        arenaCameraNeeded.Priority = 10;


    }
    private void OnTimelineFinished(int sceneIndex)
    {
        if (!IsEplorationScene())
        {
            LoadScene(0);
        }
        else
        {
            LoadScene(sceneIndex + 1);
        }
    }
    public void LoadScene(int sceneIndex)
    {
        SceneManager.LoadScene(sceneIndex,LoadSceneMode.Single);
    }
    private IEnumerator FadeCanvas(float targetAlpha, float duration)
    {
        float startAlpha = fadeImage.color.a;
        float elapsedTime = 0f;

        while (elapsedTime < duration)
        {
            elapsedTime += Time.deltaTime;
            Color newColor = fadeImage.color;
            newColor.a = Mathf.Lerp(startAlpha, targetAlpha, elapsedTime / duration);
            fadeImage.color = newColor;
            yield return null;
        }

        // Ensure the final alpha value is set correctly
        SetAlpha(targetAlpha);
    }
    private void SetAlpha(float targetAlpha)
    {
        Color finalAlpha = fadeImage.color;
        finalAlpha.a = targetAlpha;
        fadeImage.color = finalAlpha;
    }
    private bool IsEplorationScene()
    {
        // Start the scene with 50% alpha 

        if (_currentScene.buildIndex == 0 || _currentScene.name == "ExplorationScene") // You are in the  - First Person View
        {
            //thirdPersonCam.Priority = 0;
            return true;
        }
        else // You are in a Compat Scene means - Third Person View
        {
            //thirdPersonCam.Priority = 30;
            return false;
        }
    }
    private void SetFadeWhenStartScene()
    {
        SetAlpha(1);
        StartCoroutine(FadeCanvas(0, fadeDuration));
    }

}

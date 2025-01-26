using UnityEngine;


public class ExplorationManager : MonoBehaviour {
    [SerializeField] private UIManager uiManager;

    [SerializeField] private ExplorationController explorationController;

    private void Awake(){
        uiManager.OnUIChange += explorationController.ToggleControls;
    }
    private void Start(){
        BackgroundMusicController.Instance.PlayHappyBackgroundMusic();
    }
}
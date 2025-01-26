using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;


public class UIManager : MonoBehaviour {

    [Header("References")]
    [SerializeField] private Transform MainCanvas;
    [SerializeField] CutSceneManager cutSceneManager;
    [SerializeField] private InteractableManager interactableManager;

    [Header("Prefabs")]
    [SerializeField] private EncounterPrompt EncounterPromptPrefab;

    public EncounterPrompt EncounterPrompt {  get; private set; }

    [SerializeField] private EquipmentPrompt EquipmentPromptPrefab;

    private EquipmentPrompt equipmentPrompt;
    
    public event UnityAction<bool> OnUIChange;//Event for when ui is opened/closed 
    void Start()
    {
        EncounterPrompt = Instantiate(EncounterPromptPrefab, MainCanvas);

        EncounterPrompt.gameObject.SetActive(false);
        EncounterPrompt.OnSelect += SelectEncounter;

        interactableManager.OnEncounterInteract += DisplayEncounterPrompt;

        equipmentPrompt = Instantiate(EquipmentPromptPrefab, MainCanvas);
        equipmentPrompt.gameObject.SetActive(false);
        equipmentPrompt.OnSelect += SelectEquipment;

        interactableManager.OnEquipmentInteract += DisplayEquipmentPrompt;
    }

    private void DisplayEquipmentPrompt(ScriptableWeapon equipment){
        equipmentPrompt.gameObject.SetActive(true);
        equipmentPrompt.SetEquipment(equipment);
        Cursor.lockState = CursorLockMode.None;
        OnUIChange?.Invoke(true);
        
    }
    

    private void DisplayEncounterPrompt(ScriptableEncounter encounter){
        EncounterPrompt.gameObject.SetActive(true);
        EncounterPrompt.SetEncounter(encounter);
        Cursor.lockState = CursorLockMode.None;
        OnUIChange?.Invoke(true);
    }
    private void SelectEncounter(bool Confirm){
        if(Confirm){
            //cutSceneManager.LoadScene(1);
        }
        else{
            CloseUI();
        }
    }
    private void SelectEquipment(bool Confirm){
        if(Confirm){
            GameManager.Instance.SaveState.activeEquipments[equipmentPrompt.equipment] = false;
            interactableManager.EquipmentTaken(equipmentPrompt.equipment);
        }
        CloseUI();
    }
    private void CloseUI(){
        Cursor.lockState = CursorLockMode.Locked;
        OnUIChange?.Invoke(false);
    }
}
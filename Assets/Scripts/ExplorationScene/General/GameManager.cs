using UnityEngine;

public class GameManager : MonoBehaviour {
    public static GameManager Instance;
    [SerializeField] public BackgroundMusicController backgroundMusicController;


    public ScriptableWeapon EquippedWeapon;
    // private Equipment EquippedArmor;
    public ScriptableWeapon EquippedShield;

    public ScriptableWeapon EquippedArmor;


    public ScriptableEncounter currentEncounter;

    private SaveState saveState;
    public SaveState SaveState { get { return saveState; } }


    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            saveState = new SaveState();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start(){
        backgroundMusicController = FindFirstObjectByType<BackgroundMusicController>();

        BackgroundMusicController.Instance.PlayHappyBackgroundMusic();
    }  
    public void EquipWeapon(ScriptableWeapon weaponToEquip){
        EquippedWeapon = weaponToEquip;
    }

    public void SaveLastObjectCollected(Transform lastTransform)
    {
        saveState.LastObjectColllectedRot = lastTransform.rotation;
        saveState.LastObjectColllectedPos = lastTransform.position;
    }

    public Vector3 GetLastObjectPosition()
    {
        return saveState.LastObjectColllectedPos;
    }

}
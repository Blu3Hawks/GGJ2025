using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;


public class EncounterPrompt : Prompt {
    [Header("References")]

    [SerializeField] private TextMeshProUGUI DisplayText;
    [SerializeField] private Image SplashImage;

    public ScriptableEncounter encounter;

    public void SetEncounter(ScriptableEncounter encounter){
        this.encounter = encounter;
        SplashImage.sprite = encounter.EncounterSplash;
        
    }

    public override void OnConfirm()
    {
        if(GameManager.Instance != null){
            GameManager.Instance.currentEncounter = this.encounter;
        }
        base.OnConfirm();
    }


}
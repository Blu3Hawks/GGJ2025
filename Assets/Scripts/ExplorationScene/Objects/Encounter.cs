using UnityEngine;
using UnityEngine.Events;

public class Encounter : Interactable {
    //Interactable that needs to hold the enemy prefab that will be in the combat
    public event UnityAction<ScriptableEncounter> OnEncounterInteract;

    [SerializeField] private ScriptableEncounter encounter;

    public ScriptableEncounter ScriptableEncounter {get {return encounter;}}
    public override void Interact()
    {
        base.Interact();
        OnEncounterInteract?.Invoke(encounter);
    }
}
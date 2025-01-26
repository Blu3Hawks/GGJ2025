using UnityEngine;
using UnityEngine.Events;

public class EquipmentPickup : Interactable {
    //Interactable that needs to hold the equipment prefab that will be given to the player
    public event UnityAction<ScriptableWeapon> OnEquipmentInteract;

    [SerializeField] private ScriptableWeapon weapon;

    public ScriptableWeapon ScriptableWeapon {get {return weapon;}}
    public override void Interact()
    {
        base.Interact();
        OnEquipmentInteract?.Invoke(weapon);
    }
}
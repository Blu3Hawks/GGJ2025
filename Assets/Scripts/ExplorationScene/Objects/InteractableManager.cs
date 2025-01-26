using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


public class InteractableManager : MonoBehaviour{
    [SerializeField] private List<Encounter> Encounters;//All encounters in the level

    [SerializeField] private List<EquipmentPickup> Equipments;//All equipments in the level

    public event UnityAction<ScriptableEncounter> OnEncounterInteract;

    public event UnityAction<ScriptableWeapon> OnEquipmentInteract;

    void Start(){
        SaveState currentSave = GameManager.Instance.SaveState;
        foreach(Encounter encounter in Encounters){
            if(encounter == null) break;
            encounter.OnEncounterInteract += ShowEncounterUI;
            if(!currentSave.activeEncounters.ContainsKey(encounter.ScriptableEncounter)){
                currentSave.activeEncounters.Add(encounter.ScriptableEncounter, true);
            }
            else{
                if(currentSave.activeEncounters[encounter.ScriptableEncounter] == false){
                    encounter.gameObject.SetActive(false);
                }
            }

        }
        foreach(EquipmentPickup equipment in Equipments){
            if(equipment == null) break;
            equipment.OnEquipmentInteract += ShowEquipmentUI;
            if(!currentSave.activeEquipments.ContainsKey(equipment.ScriptableWeapon)){
                currentSave.activeEquipments.Add(equipment.ScriptableWeapon, true);
            }
            else{
                if(currentSave.activeEquipments[equipment.ScriptableWeapon] == false){
                    equipment.gameObject.SetActive(false);
                }
            }
        }
    }

    private void ShowEncounterUI(ScriptableEncounter encounter){//To be replaced with encounter
        OnEncounterInteract?.Invoke(encounter);
    }
    private void ShowEquipmentUI(ScriptableWeapon equipment){//To be replaced with equipment
        OnEquipmentInteract?.Invoke(equipment);
    }
    public void EquipmentTaken(ScriptableWeapon equipment){
        GameManager.Instance.SaveState.activeEquipments[equipment] = false;
        foreach(EquipmentPickup pickup in Equipments){
            if(pickup.ScriptableWeapon == equipment){
                pickup.gameObject.SetActive(false);
            }
        }
    }
}
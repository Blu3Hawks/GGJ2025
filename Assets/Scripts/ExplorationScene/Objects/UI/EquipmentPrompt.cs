using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class EquipmentPrompt : Prompt {
    [Header("References")]

    [SerializeField] private TextMeshProUGUI DisplayText;

    [SerializeField] private Image IconImage;

    public ScriptableWeapon equipment;

    public void SetEquipment(ScriptableWeapon equipment){
        this.equipment = equipment;
        IconImage.sprite = equipment.WeaponIcon;
        DisplayText.SetText(equipment.WeaponName);
    }

    public override void OnConfirm()
    {
        if(GameManager.Instance != null){
            switch(this.equipment.equipmentType){
                case EquipmentTypes.Weapon:
                    GameManager.Instance.EquippedWeapon = this.equipment;
                    break;
                case EquipmentTypes.Armor:
                    GameManager.Instance.EquippedArmor = this.equipment;
                    break;
                case EquipmentTypes.Shield:
                    GameManager.Instance.EquippedShield = this.equipment;
                    break;
            }
            GameManager.Instance.SaveState.activeEquipments[this.equipment] = false;
        }
        base.OnConfirm();
    }

}
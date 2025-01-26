using UnityEngine;
public enum EquipmentTypes {
    Weapon,
    Armor,
    Shield
}
[CreateAssetMenu(fileName = "ScriptableWeapon", menuName = "Scriptable Objects/ScriptableWeapon")]
public class ScriptableWeapon : ScriptableObject
{
    [SerializeField] private string weaponName;

    public string WeaponName {get {return weaponName;}}

    [SerializeField] private Weapon weaponPrefab;

    public Weapon WeaponPrefab {get {return weaponPrefab;}}

    [SerializeField] private Sprite weaponIcon;

    public Sprite WeaponIcon {get {return weaponIcon;}}

    [SerializeField] public EquipmentTypes equipmentType;



}

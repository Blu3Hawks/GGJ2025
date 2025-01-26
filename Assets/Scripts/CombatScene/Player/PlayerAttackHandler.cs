using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.VFX;

public enum attackTypes {
    Light,
    Heavy,
    Quick,
    Fists
}
public class PlayerAttackHandler : MonoBehaviour
{

    [Header("Combat Components")]
    [SerializeField] private GameObject sword;
    [SerializeField] private GameObject shield;
    [SerializeField] private GameObject armor;

    [SerializeField] private ScriptableWeapon DefaultWeapon;
    [SerializeField] private ScriptableWeapon DefaultShield;

    [SerializeField] private VisualEffect slashVFX;

    public Weapon EquippedWeapon;

    public Weapon EquippedShield;
    public Weapon EquippedArmor;

    [Header("Combat Movement")]
    [SerializeField] private Animator animator;
    [SerializeField] private CharacterController characterController;
    private static readonly int attackHash = Animator.StringToHash("Attack");

    private static readonly int attackTypeHash = Animator.StringToHash("AttackType");


    private bool _isBlocking = false;
    private bool _isAttacking = false;

    private int comboCounter = 0;

    private void Awake()
    {
        sword.SetActive(true);
        shield.SetActive(false);
    }
    private void Start(){
        ScriptableWeapon WeaponToLoad = GameManager.Instance.EquippedWeapon;
        if(WeaponToLoad == null){
            WeaponToLoad = DefaultWeapon;
        }
        EquippedWeapon = Instantiate(WeaponToLoad.WeaponPrefab, sword.transform);
        animator.SetInteger(attackTypeHash, (int)EquippedWeapon.AttackType);

        ScriptableWeapon ShieldToLoad = GameManager.Instance.EquippedShield;
        if(ShieldToLoad == null){
            ShieldToLoad = DefaultShield;
        }
        EquippedShield = Instantiate(ShieldToLoad.WeaponPrefab, shield.transform);

        ScriptableWeapon ArmorToLoad = GameManager.Instance.EquippedArmor;
        if(ArmorToLoad == null){
            ArmorToLoad = DefaultWeapon;
        }
        EquippedArmor = Instantiate(ArmorToLoad.WeaponPrefab, armor.transform);
        
    }

    public void OnPlayerBlock(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            _isBlocking = true;
            shield.SetActive(_isBlocking);
            Debug.Log(_isBlocking);
        }
        else if (context.canceled)
        {
            _isBlocking = false;
            shield.SetActive(_isBlocking);
            Debug.Log(_isBlocking);
        }
    }

    public void OnPlayerAttack(InputAction.CallbackContext context)
    {
        if (context.started && comboCounter < (EquippedWeapon.AttackType == attackTypes.Light ? 3 : 2))
        {
            animator.SetTrigger(attackHash);
        }
    }

    
    public void SetAttacking(bool attacking){
        characterController.enabled = !attacking;//if attacking should be disabled
        _isAttacking = attacking;
        // if(attacking){
        //     StartCoroutine(ControlColliders());
        // }
    }
    public void IncreaseComboCount(){
        comboCounter++;
        StartCoroutine(ControlColliders());

    }
    public void ResetCombo(){
        comboCounter = 0;
        ToggleEquipment(false);
    }
    public void ToggleEquipment(bool enable){
        EquippedWeapon.ToggleColliders(enable);
    }

    public IEnumerator ControlColliders(){
            EquippedWeapon.ToggleColliders(false);

            yield return new WaitForSeconds(0.15f);
            EquippedWeapon.ToggleColliders(true);
            yield return new WaitForSeconds(0.1f);
            slashVFX.Stop();
            slashVFX.Play();

    }
}

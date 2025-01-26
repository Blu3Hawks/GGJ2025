using UnityEngine;
using UnityEngine.Events;

public class WeaponHandler : MonoBehaviour
{
    [SerializeField] private PlayerCombatManager playerManager;
    private float damage;

    private void Awake()
    {
        if (playerManager == null)
        {
            playerManager = GetComponentInParent<PlayerCombatManager>();
        }
        SetDamage(playerManager.Damage);
    }

    public void SetDamage(float newDamage)
    {
        damage = newDamage;
    }

    
}

using UnityEngine;

public class PlayerCombatManager : MonoBehaviour
{
    [Header("Player Stats")]
    [SerializeField] private float maxHealth;
    [SerializeField] private float damage;

    private float currentHealth;

    private void Awake()
    {
        currentHealth = maxHealth;
    }
    public float Health { get { return maxHealth; } }
    public float Damage { get { return damage; } }

    public void TakeDamage(CombatArgs combatArgs)
    {
        currentHealth -= combatArgs.Damage;
    }
}

using UnityEngine;

public class EnemyWeaponHandler : MonoBehaviour
{
    [SerializeField] private float damage;
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            PlayerCombatHitbox player = other.gameObject.GetComponentInParent<PlayerCombatHitbox>();
            if (player != null)
            {
                // Debug.Log("did you really think i needed all the guards at the hexgates");
                player.TriggerOnTakeDamage(DealDamage());
            }
        }
    }

    public CombatArgs DealDamage()
    {
        CombatArgs args = new CombatArgs()
        {
            Damage = damage
        };
        // Debug.Log(args.Damage);
        return args;
    }
}

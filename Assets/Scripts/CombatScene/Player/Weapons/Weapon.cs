using UnityEngine;

public class Weapon : MonoBehaviour {
    [SerializeField] private Collider attackCollider;

    [SerializeField] private Collider secondaryCollider;

    [SerializeField] private ParticleSystem HitVFX;

    [SerializeField] private attackTypes attackType;

    public attackTypes AttackType{get {return attackType;}}

    [SerializeField] private float damage;

    [SerializeField] private EquipmentTypes type;
    public void ToggleColliders(bool enable){
        attackCollider.enabled = enable;
        if(secondaryCollider != null){
            secondaryCollider.gameObject.SetActive(enable);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Enemy") && type == EquipmentTypes.Weapon)
        {
            Debug.Log(other.name);
            EnemyCombatHitbox enemy = other.gameObject.GetComponent<EnemyCombatHitbox>();
            if (enemy != null)
            {
                Debug.Log("Enemy comp was found");
                enemy.TriggerOnTakeDamage(DealDamage());
                Instantiate(HitVFX, enemy.transform.position, Quaternion.identity);
            }
            else
            {
                Debug.Log("We didn't find enemy");
            }
        }
    }

    public CombatArgs DealDamage()
    {
        CombatArgs args = new CombatArgs()
        {
            Damage = damage,
            Source = transform.position
        };
        return args;
    }
}
using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Events;

public class EnemyManager : MonoBehaviour
{
    [SerializeField] private float maxHealth;
    [SerializeField] private EnemyCombatHitbox hitbox;

    [SerializeField] private EnemyMovement enemyMovement;

    [SerializeField] private Rigidbody rb;
    [SerializeField] private SFXClipsData hitClips;



    private float currentHealth;

    public event UnityAction OnEnemyDeath;
    private GameObject player;

    private bool isKnockedBack;

    private void Start()
    {
        currentHealth = maxHealth;
        hitbox.OnTakeDamage += TakeDamage;
    }

    public void TakeDamage(CombatArgs hitStats)
    {
        currentHealth -= hitStats.Damage;
        Vector3 direction = new Vector3((transform.position - hitStats.Source).normalized.x,0, (transform.position - hitStats.Source).normalized.z);
        ApplyKnockback(direction , 2, 0.3f);
        Debug.Log(currentHealth);

        AudioClip hitClip = hitClips.getClipToUse();
        BackgroundMusicController.Instance.playSFX(hitClip);

        if (currentHealth <= 0)
        {
            OnEnemyDeath?.Invoke();
            Debug.Log("Enemy was destroyed");
            Destroy(gameObject);
        }
    }
    public void AssignPlayer(GameObject player){
        this.player = player;
        enemyMovement.AssignPlayer(player);
    }

    public void ApplyKnockback(Vector3 knockbackDirection, float knockbackForce, float duration)
    {
        StartCoroutine(KnockbackWithRigidbody(knockbackDirection.normalized * knockbackForce, duration));
    }

    private IEnumerator KnockbackWithRigidbody(Vector3 force, float duration)
    {
        isKnockedBack = true;
        enemyMovement.ToggleAgent(false); // Disable NavMeshAgent
        if (rb != null)
        {
            rb.isKinematic = false; // Ensure Rigidbody can move freely
            rb.AddForce(force, ForceMode.Impulse);
        }

        yield return new WaitForSeconds(duration);

        if (rb != null)
            rb.isKinematic = true; // Restore kinematic state

        enemyMovement.ToggleAgent(true); // Re-enable NavMeshAgent
        isKnockedBack = false;
    }
}

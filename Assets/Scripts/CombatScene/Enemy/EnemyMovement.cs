using UnityEngine;
using UnityEngine.AI;

public class EnemyMovement : MonoBehaviour
{
    [Header("Movement & Navmesh")]
    [SerializeField] private NavMeshAgent agent;

    private GameObject player;

    [Header("Animation")]
    [SerializeField] private Animator animator;
    [Header("Sounds")]
    [SerializeField] private SFXClipsData attackClips;
    private static readonly int speedHash = Animator.StringToHash("Movespeed");
    private static readonly int attackHash = Animator.StringToHash("Attack");

    [Header("Combat Settings")]
    [SerializeField] private float attackRange;  
    [SerializeField] private float attackCooldown = 1.5f; //feel free to change, it's the animation's length
    private float _nextAttackTime = 0f; // counter

    private void Awake()
    {
        attackRange = agent.stoppingDistance;
    }
    private void Update()
    {
        EnemyBasicMovement();
        InitiateAttack();
    }

    private void InitiateAttack()
    {
        if(player == null || !agent.enabled)return;
        float distanceToPlayer = Vector3.Distance(transform.position, player.transform.position);
        if (distanceToPlayer <= attackRange)
        {
            agent.velocity = Vector3.zero;
            agent.isStopped = true; 

            if (Time.time >= _nextAttackTime)
            {
                AttackPlayer();
                _nextAttackTime = Time.time + attackCooldown;
            }

        }
        else
        {
            agent.isStopped = false;
        }
    }

    private void EnemyBasicMovement()
    {
        if (agent.enabled && player != null)
        {
            //set targe
            agent.SetDestination(player.transform.position);
            //set the float correctly
            float currentSpeed = agent.velocity.magnitude;
            animator.SetFloat(speedHash, currentSpeed);
            agent.transform.LookAt(player.transform.position);

        }
        else
        {
            //if the agent's disabled,well..
            animator.SetFloat(speedHash, 0);
        }
        //always rotate
    }

    private void AttackPlayer()
    {
        animator.SetTrigger(attackHash);
        AudioClip attackClip = attackClips.getClipToUse();
        BackgroundMusicController.Instance.playSFX(attackClip);
        //add stuff here idk
    }

    public void AssignPlayer(GameObject player){
        this.player = player;
    }

    public void ToggleAgent(bool enable){
        agent.enabled = enable;
    }
}

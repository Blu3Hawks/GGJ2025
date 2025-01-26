using UnityEngine;


public class AttackStateMachine : StateMachineBehaviour {
    private PlayerAttackHandler playerAttackHandler;
    public override void OnStateMachineEnter(Animator animator, int stateMachinePathHash)
    {
        base.OnStateMachineEnter(animator, stateMachinePathHash);
        if(playerAttackHandler == null){
            playerAttackHandler = animator.GetComponentInParent<PlayerAttackHandler>();
        }
        if(playerAttackHandler != null){
            playerAttackHandler.SetAttacking(true);
        }
        else{
            Debug.Log($"Couldn't Find attack handler in {animator.gameObject.name}");
        }
    }
    public override void OnStateMachineExit(Animator animator, int stateMachinePathHash)
    {
        base.OnStateMachineExit(animator, stateMachinePathHash);
        if(playerAttackHandler == null){
            playerAttackHandler = animator.GetComponentInParent<PlayerAttackHandler>();
        }
        if(playerAttackHandler != null){
            playerAttackHandler.SetAttacking(false);
            playerAttackHandler.ResetCombo();
        }
        else{
            Debug.Log("Couldn't Find attack handler");
        }
    }
    public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateEnter(animator, stateInfo, layerIndex);
        if(playerAttackHandler != null){
            playerAttackHandler.IncreaseComboCount();
        }
        else{
            Debug.Log("Couldn't Find attack handler");
        }
    }
}
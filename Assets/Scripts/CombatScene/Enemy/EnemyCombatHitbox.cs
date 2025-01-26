using UnityEngine;
using UnityEngine.Events;

public class EnemyCombatHitbox : MonoBehaviour
{
    public event UnityAction<CombatArgs> OnTakeDamage;

    public void TriggerOnTakeDamage(CombatArgs combatArgs)
    {
        OnTakeDamage?.Invoke(combatArgs);
    }
}


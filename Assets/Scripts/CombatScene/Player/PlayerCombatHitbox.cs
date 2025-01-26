using UnityEngine;
using UnityEngine.Events;

public class PlayerCombatHitbox : MonoBehaviour
{
    public event UnityAction<CombatArgs> OnTakeDamage;
    public void TriggerOnTakeDamage(CombatArgs combatArgs)
    {
        OnTakeDamage?.Invoke(combatArgs);
    }
}

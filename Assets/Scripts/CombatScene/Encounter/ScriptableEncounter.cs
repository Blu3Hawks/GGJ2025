using UnityEngine;

[CreateAssetMenu(fileName = "ScriptableEncounter", menuName = "Scriptable Objects/ScriptableEncounter")]
public class ScriptableEncounter : ScriptableObject
{
    [SerializeField] private EnemyManager enemyPrefab;

    public EnemyManager EnemyPrefab {get {return enemyPrefab;}}

    [Range(1, 10)]
    [SerializeField] private int amountToSpawn;

    public int AmountToSpawn {get {return amountToSpawn;}}

    [SerializeField] private Sprite encounterSplash;

    public Sprite EncounterSplash {get {return encounterSplash;}}


}

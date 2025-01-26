using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;


public class EncounterManager : MonoBehaviour {

    public event UnityAction AllEnemisDied;

    [Header("Scene references")]
    [SerializeField] private List<Transform> SpawnOrigin;
    [SerializeField] private GameObject Player;

    [Header("References from project")]

    private ScriptableEncounter currentEncounter;


    private int enemyCount;
    void Start(){
        currentEncounter = GameManager.Instance.currentEncounter;
        for(int i = 0; i< currentEncounter.AmountToSpawn;i++){
            EnemyManager enemy = Instantiate(currentEncounter.EnemyPrefab, SpawnOrigin[i%SpawnOrigin.Count]);
            enemy.OnEnemyDeath += UpdateEnemyCount;
            enemyCount++;
            enemy.AssignPlayer(Player);
        }
        BackgroundMusicController.Instance.PlayCombatBackgroundMusic();
        
    }

    private void UpdateEnemyCount(){
        enemyCount--;
        if(enemyCount <= 0){
            GameManager.Instance.SaveState.activeEncounters[currentEncounter] = false;
            SceneManager.LoadScene("Exploration");
        }
    }
}
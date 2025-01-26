using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;


public class PlayerInteractor : MonoBehaviour {
    [Header("References")]
    [HideInInspector] public CutSceneManager CutSceneManager;
    [SerializeField] private Transform ItemHeldParent;

    private Interactable _heldInteractable;
    private List<Interactable> interactablesInRange = new List<Interactable>();

    private void OnTriggerEnter(Collider other){
        if(other.CompareTag("Interactable")){
            Interactable interactable = other.GetComponent<Interactable>();
            if(interactable != null){
                interactablesInRange.Add(interactable);
                SetCurrentInteractable();
            }
        }
    }
    private void OnTriggerExit(Collider other){
        if(other.CompareTag("Interactable")){
            Interactable interactable = other.GetComponent<Interactable>();
            if(interactable != null){
                if(interactablesInRange.Contains(interactable)){
                    interactablesInRange.Remove(interactable);
                }
            }
        }
    }
    public void OnInteract(InputAction.CallbackContext context)
    {
        if (interactablesInRange.Count > 0)
        {
            Interactable CurrentInteractable = interactablesInRange[interactablesInRange.Count - 1];
            CurrentInteractable.Interact();
        }
    }
    private void SetCurrentInteractable()
    {
        if (CutSceneManager == null || interactablesInRange.Count <= 0) return;

        CutSceneManager.TryChangeCollectedObject(interactablesInRange[interactablesInRange.Count - 1].transform);
        //Debug.Log("Set Interacted Object Tranform");
    }

}
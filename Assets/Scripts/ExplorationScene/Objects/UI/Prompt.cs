using UnityEngine;
using UnityEngine.Events;


public class Prompt : MonoBehaviour {

    public event UnityAction<bool> OnSelect;

    public virtual void OnConfirm(){
        gameObject.SetActive(false);
        OnSelect?.Invoke(true);
    } 

    public virtual void OnDeny(){
        gameObject.SetActive(false);
        OnSelect?.Invoke(false);

    }
}
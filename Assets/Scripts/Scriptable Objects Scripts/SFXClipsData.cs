using UnityEngine;
using System.Collections.Generic; // Ensure this is included for List<T>


[CreateAssetMenu(fileName = "SFXClipsData", menuName = "Scriptable Objects/SFXClipsData")]
public class SFXClipsData : ScriptableObject
{
    [SerializeField] string text;

    [SerializeField] private List<AudioClip> audioClips; // List<AudioClip> should show up in the Inspector
    private System.Random random = new System.Random(); // Fixed random initialization

    public AudioClip getClipToUse(){
        return getRandomClipFrom(audioClips); // Pass the List directly
    }

    public AudioClip getRandomClipFrom(List<AudioClip> audioClips){ // Make sure this method expects List<AudioClip>
        int randomIndex = Random.Range(0, audioClips.Count);
        return audioClips[randomIndex];
    }
}

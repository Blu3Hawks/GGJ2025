using UnityEngine;
using DG.Tweening;

public class BackgroundMusicController : MonoBehaviour
{
    public static BackgroundMusicController Instance; 
    [SerializeField] private AudioSource flute;
    [SerializeField] private AudioSource happy;
    [SerializeField] private AudioSource combat;
    [SerializeField] private AudioSource sfxAudioSource;
    
    [SerializeField] private float TransitionDuration = 0.4f;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
    private void Start()
    {
        PlayAllAudioSources();
        SetInitialVolumes();
    }

    private void PlayAllAudioSources()
    {
        flute.Play();
        happy.Play();
        combat.Play();
    }

    private void SetInitialVolumes()
    {
        flute.volume = 1.0f;
        happy.volume = 0.0f;
        combat.volume = 0.0f;

        sfxAudioSource.volume = 1.0f;
    }

    public void PlayHappyBackgroundMusic()
    {
        fadeOut(combat);
        fadeIn(happy);
    }

    public void PlayCombatBackgroundMusic()
    {
        Debug.Log("Combat");
        fadeOut(happy);
        fadeIn(combat);
    }

    public void fadeOut(AudioSource audioSource){
        audioSource.DOFade(0.0f, TransitionDuration);
    }
    public void fadeIn(AudioSource audioSource){
        audioSource.DOFade(1.0f, TransitionDuration);
    }

    public void playSFX(AudioClip audioClip){
        sfxAudioSource.PlayOneShot(audioClip);
    }
}
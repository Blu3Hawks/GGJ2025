using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;


public class ExplorationController : MonoBehaviour {

    [Header("References")]
    [SerializeField] private CharacterController characterController;
    [SerializeField] private SFXClipsData stepsClips;
    [SerializeField] private float timeBetweenSteps = 0.4f; // Default time interval between steps (adjustable)
    private float timeSinceLastStep = 0f; // Tracks time since the last step sound was played


    [SerializeField] private CinemachineCamera FOVcamera;


    [SerializeField] private float MoveSpeed;

    [Header("Player settings")]

    [SerializeField] private float VerticalSensitivity = 1;
    [SerializeField] private float HorizontalSensitivity = 1;

    [Header("Private fields")]
    private float xRotation;
    private float yRotation;
    private Vector3 _playerDirection;

    private Vector2 _playerInput;
    private float cameraPitch;

    private bool LockControls = false;
    
    void Start(){
        Cursor.lockState = CursorLockMode.Locked;
        if(GameManager.Instance.SaveState.playerPosition != null){
            transform.position = GameManager.Instance.SaveState.playerPosition;
        }
        if(GameManager.Instance.SaveState.playerRotation != null){
            transform.rotation = GameManager.Instance.SaveState.playerRotation;
        }
        cameraPitch = GameManager.Instance.SaveState.cameraPitch;
        FOVcamera.transform.localRotation = Quaternion.Euler(cameraPitch, 0, 0);

    }
    void Update(){
        
        Movement();
        Look();
        if (characterController.isGrounded == false)
        {
            //Add our gravity Vecotr
            characterController.Move(Physics.gravity); 
        }
        
    }

    public void OnPlayerLook(InputAction.CallbackContext context)
    {
        if(LockControls){
            xRotation = 0;
            yRotation = 0;
            return;
        }

        Vector2 _lookInput = context.ReadValue<Vector2>();

        xRotation = _lookInput.x;
        yRotation = _lookInput.y;
    }

    private void Look(){
        transform.Rotate(Vector3.up*xRotation*HorizontalSensitivity*Time.deltaTime);
        cameraPitch -= yRotation*VerticalSensitivity*Time.deltaTime; // Subtract because yRotation is typically inverted for "looking up"
        cameraPitch = Mathf.Clamp(cameraPitch, -90f, 90f);
        FOVcamera.transform.localRotation = Quaternion.Euler(cameraPitch, 0, 0);
    }

    private void Movement(){
        if(LockControls){
            characterController.Move(Vector3.zero);
            return;
        }
        _playerDirection = transform.right * _playerInput.x + transform.forward * _playerInput.y;
        characterController.Move( _playerDirection * MoveSpeed * Time.deltaTime);
        
        if (characterController.velocity != Vector3.zero){
            PlayStepSound();
        }
    }

    private void PlayStepSound()
    {
        // Only play the sound if enough time has passed since the last step
        if (timeSinceLastStep >= timeBetweenSteps)
        {
            // Get a random step clip and play it
            AudioClip stepClip = stepsClips.getClipToUse();
            BackgroundMusicController.Instance.playSFX(stepClip);
            // Reset the time counter
            timeSinceLastStep = 0f;
        }

        // Update the timer based on the time passed since the last step
        timeSinceLastStep += Time.deltaTime;
    }

    public void OnPlayerMovement(InputAction.CallbackContext context)
    {
        
        _playerInput = context.ReadValue<Vector2>();
        
    }

    public void ToggleControls(bool LockControls){
        this.LockControls = LockControls;
    }
    void OnDisable(){
        GameManager.Instance.SaveState.playerPosition = transform.position;
        GameManager.Instance.SaveState.playerRotation = transform.rotation;
        GameManager.Instance.SaveState.cameraPitch = cameraPitch;
    }


}
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    //references
    [Header("Character Components")]
    [SerializeField] private CharacterController characterController;
    [SerializeField] private PlayerMovementSettings playerMovementSettings;

    [Header("Amimations")]
    [SerializeField] private Animator animator;

    private static readonly int speedHash = Animator.StringToHash("Movespeed");



    //values of the input
    private Vector2 _playerInput;
    //direction of the input
    private Vector3 _playerDirection;
    //our player's gravitational velocity
    private float _playerGravitationalVelocity;

    //player's current rotation velocity
    private float _playerRotationDirection;
    //check the if the player finished to rotate

    private void Update()
    {
        PlayerRotation();
        Movement();
        // ApplyGravity();
    }

    private void Movement()
    {
        if (characterController.enabled)
        {
            characterController.Move(_playerDirection * playerMovementSettings.PlayerMovementSpeed * Time.deltaTime);
            animator.SetFloat(speedHash, characterController.velocity.magnitude);
        }
    }

    public void OnPlayerMovement(InputAction.CallbackContext context)
    {
        _playerInput = context.ReadValue<Vector2>();
        _playerDirection = new Vector3(_playerInput.x, 0, _playerInput.y);
    }
    private void PlayerRotation()
    {
        //if no changes in inputs then we don't need to keep going and change the rotation
        if (_playerInput.sqrMagnitude == 0 || !characterController.enabled) { return; }
        //calculate the degree of the angle that we want to look at
        float angleToRotate = Mathf.Atan2(_playerDirection.x, _playerDirection.z) * Mathf.Rad2Deg;
        //make a smooth transition between the angles - between the current angle and the new inputted angle
        float angle = Mathf.SmoothDampAngle(
            characterController.transform.eulerAngles.y,
            angleToRotate,
            ref _playerRotationDirection,
            playerMovementSettings.PlayerRotationSpeed * Time.deltaTime
        );

        //calculate the differences between the angles. Since the .Rotate is applying constant change to the angle,
        //it adds every time more to the angle - so we need to calculate, as we walk, the differences between the
        //angles, and apply them. Once the differences are 0 we no longer rotate
        float angleDifferences = Mathf.DeltaAngle(characterController.transform.eulerAngles.y, angle);
        //actually translate the rotation
        characterController.transform.Rotate(Vector3.up, angleDifferences);
    }

    private void ApplyGravity()
    {
        //if we are on the ground, and somehow if the player's velocity is less than 0 by any other... stuff
        if (characterController.isGrounded && _playerGravitationalVelocity < 0f)
        {
            _playerGravitationalVelocity = 0f;
        }
        else
        {
            _playerGravitationalVelocity += playerMovementSettings.PlayerGravityValue * playerMovementSettings.PlayerGravityMultiplier * Time.deltaTime;
        }
        //apply the velocity properly
        _playerDirection.y = _playerGravitationalVelocity;
    }



}

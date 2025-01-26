using UnityEngine;

[CreateAssetMenu(fileName = "PlayerMovementValues", menuName = "Scriptable Objects/Player/PlayerMovementValues")]

[System.Serializable]
public class PlayerMovementSettings : ScriptableObject
{

    [Header("Character Stats")]
    [SerializeField] private float movementSpeed = 5f;
    //quickness of the player's rotation when moving around
    [SerializeField] private float rotationSmoothnessSpeed = 8f; //works best for now I guess

    [Header("Gravity")]
    //in case we'd ever want to change it ?
    [SerializeField] private float gravityValue = -9.81f;
    [SerializeField] private float gravityMultiplier = 3.0f;

    public float PlayerMovementSpeed
    {
        get { return movementSpeed; }
    }
    public float PlayerRotationSpeed
    {
        get { return rotationSmoothnessSpeed; }
    }
    public float PlayerGravityValue
    {
        get { return gravityValue; }
    }
    public float PlayerGravityMultiplier
    {
        get { return gravityMultiplier; }
    }

}

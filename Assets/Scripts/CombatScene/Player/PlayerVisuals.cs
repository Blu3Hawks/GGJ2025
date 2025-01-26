using UnityEngine;

public class PlayerVisuals : MonoBehaviour
{
    [Header("New Visuals")]
    [Header("New Shield Visuals")]
    [SerializeField] private GameObject newShieldObject;
    [SerializeField] private MeshFilter newShieldFilter;
    [SerializeField] private MeshRenderer newShieldRenderer;
    [SerializeField] private MeshCollider newShieldCollider;

    [Header("New Sword Visuals")]
    [SerializeField] private GameObject newSwordObject;
    [SerializeField] private MeshFilter newSwordFilter;
    [SerializeField] private MeshRenderer newSwordRenderer;
    [SerializeField] private MeshCollider newSwordCollider;

    [Header("Current Visuals")]
    [Header("Current Shield In Scene")]
    [SerializeField] private GameObject currentShieldObject;
    [SerializeField] private MeshFilter shieldFilter;
    [SerializeField] private MeshRenderer shieldRenderer;
    [SerializeField] private MeshCollider shieldMeshCollider;

    [Header("Current Sword In Scene")]
    [SerializeField] private GameObject currentSwordObject;
    [SerializeField] private MeshFilter swordFilter;
    [SerializeField] private MeshRenderer swordRenderer;
    [SerializeField] private MeshCollider swordMeshCollider;

    private void Start()
    {
        ApplyShieldVisualModification();
        ApplySwordVisualModification();
    }

    public void ApplyShieldVisualModification()
    {
        if (shieldFilter != null && newShieldFilter != null)
        {
            shieldFilter.sharedMesh = newShieldFilter.sharedMesh;
        }
        if (shieldRenderer != null && newShieldRenderer != null)
        {
            shieldRenderer.sharedMaterials = newShieldRenderer.sharedMaterials;
        }

        if (shieldMeshCollider != null && newShieldCollider != null)
        {
            shieldMeshCollider.sharedMesh = newShieldCollider.sharedMesh;
            shieldMeshCollider.convex = newShieldCollider.convex;
        }

        if (currentShieldObject != null && newShieldObject != null)
        {
            currentShieldObject = newShieldObject;
        }
    }


    public void ApplySwordVisualModification()
    {
        if (swordFilter != null && newSwordFilter != null)
        {
            swordFilter.sharedMesh = newSwordFilter.sharedMesh;
        }

        if (swordRenderer != null && newSwordRenderer != null)
        {
            swordRenderer.sharedMaterials = newSwordRenderer.sharedMaterials;
        }

        if (swordMeshCollider != null && newSwordCollider != null)
        {
            swordMeshCollider.sharedMesh = newSwordCollider.sharedMesh;
            swordMeshCollider.convex = newSwordCollider.convex;
        }
        if (currentSwordObject != null && newSwordObject != null)
        {
            currentSwordObject = newSwordObject;
        }

    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        ApplyShieldVisualModification();
        ApplySwordVisualModification();
    }
#endif
}

using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(PlayerVisuals))]
public class PlayerVisualsEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        PlayerVisuals playerVisuals = (PlayerVisuals)target;
        if (GUILayout.Button("Apply Visuals"))
        {
            playerVisuals.ApplyShieldVisualModification();
            playerVisuals.ApplySwordVisualModification();
        }
    }
}
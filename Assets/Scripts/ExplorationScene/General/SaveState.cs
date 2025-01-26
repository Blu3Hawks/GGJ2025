using System.Collections.Generic;
using UnityEngine;


public class SaveState
{
    public Vector3 playerPosition = new Vector3(4.784f, 0.681f, 4.038f);

    public Quaternion playerRotation;

    public float cameraPitch;

    public Vector3 LastObjectColllectedPos;
    public Quaternion LastObjectColllectedRot;

    public Dictionary<ScriptableEncounter, bool> activeEncounters;

    public Dictionary<ScriptableWeapon, bool> activeEquipments;


    public SaveState()
    {
        activeEncounters = new Dictionary<ScriptableEncounter, bool>();
        activeEquipments = new Dictionary<ScriptableWeapon, bool>();
    }

    public void SaveLastPosition(Vector3 lastPos, Quaternion lastRot)
    {
        LastObjectColllectedPos = lastPos;
        LastObjectColllectedRot = lastRot;
    }
}
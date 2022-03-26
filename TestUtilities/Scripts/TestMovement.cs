using Godot;
using System;

public class TestMovement : Spatial
{ 
    [Export]
    private float amplitude = 1f;

    public override void _Process(float delta)
    {
        float seconds = OS.GetTicksMsec() / 1000f;
        float x = Mathf.Sin(seconds) * amplitude;
        Translation = new Vector3(x, Translation.y, Translation.z);
    }
}

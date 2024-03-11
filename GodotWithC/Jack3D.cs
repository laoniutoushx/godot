using Godot;
using System;

public partial class Jack3D : Sprite3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{

		var inputVec = new Vector3(Input.GetAxis("ui_left", "ui_right"),Input.GetAxis("ui_up", "ui_down"), 0);
		GD.Print(inputVec);
		GlobalPosition += inputVec * 10;

	}
}

using Godot;
using System;
using System.Diagnostics;
using System.Runtime.CompilerServices;

public partial class Player : RigidBody3D
{


	[Export]
	private float mouseSensitivity = 0.001f;
	[Export]
	private float twistInput = 0.0f;
	[Export]
	private float pitchInput = 0.0f;

	private Node3D twistPivot;
	private Node3D pitchPivot;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
		Input.MouseMode = Input.MouseModeEnum.Captured;
		twistPivot = GetNode<Node3D>("TwistPivot");
		pitchPivot = GetNode<Node3D>("TwistPivot/PitchPivot");

	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		Vector3 input = Vector3.Zero;
		input.X = Input.GetAxis("move_left", "move_right");
		input.Z = Input.GetAxis("move_forward", "move_back");

		// ApplyCentralForce(input * 1200.0f * (float)delta);
		ApplyCentralForce(twistPivot.Basis * input * 1200.0f * (float)delta);
		

		if(Input.IsActionJustPressed("ui_cancel")){
			Input.MouseMode = Input.MouseModeEnum.Visible;
		}

		
		twistPivot.RotateY(twistInput);
		pitchPivot.RotateX(pitchInput);
		// pitchPivot._Set("rotation", Math.Clamp(pitchPivot.Rotation.X, -0.5, 0.5));
		//  -30° ~ 30°
		pitchPivot.Rotation = new Vector3((float) Math.Clamp(pitchPivot.Rotation.X, -0.5, 0.5), pitchPivot.Rotation.Y, pitchPivot.Rotation.Z);

		twistInput = 0.0f;
		pitchInput = 0.0f;

	}


    // 按键响应
    //  按键响应有两种方式，第一种方式是重载按键检测方法，第二种方式是使用官方的按键动作映射。

	// 重载按键检测
 	// 这种方法十分直观，只需要重载_UnhandledInput方法，并检测对应键的值即可，但缺点是多设备适应能力。
	public override void _UnhandledInput(InputEvent @event){
		if(@event is InputEventMouseMotion eventMouseMotion){
			if(Input.MouseMode == Input.MouseModeEnum.Captured){
				twistInput = - eventMouseMotion.Relative.X * mouseSensitivity;
				pitchInput = - eventMouseMotion.Relative.Y * mouseSensitivity;
				Console.WriteLine(twistInput);
			}
		}
	}
	
}

extends RigidBody3D


var val:int = 0

## how much vertical force to apply when launch
@export_range(200, 10000) var thrust: float = 1000.0
@export_range(10, 500) var torque_thrust: float = 100.0

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio

 
var is_transactioning = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()
 	
	if Input.is_action_pressed("left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))

 	
	if Input.is_action_pressed("right"):
		apply_torque(Vector3(0.0, 0.0, - torque_thrust * delta))


func _on_body_entered(body: Node) -> void:
	if is_transactioning == false:
		if "Landing" in body.get_groups():
			print(body.name + " - You Win!!!")
			complete_level(body.file_path)
			
		if "Floor" in body.get_groups():
			print(body.name + " - You Failed!!!")
			crash_sequence()

func crash_sequence() -> void:
	explosion_audio.play()
	print("KABOOM!")
	is_transactioning = true
	set_process(false)
	var tween = get_tree().create_tween()
	tween.tween_interval(1)
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_path) -> void:
	success_audio.play()
	print("Level Complete")
	# get_tree().quit()
	is_transactioning = true
	set_process(false)
	var tween = get_tree().create_tween()
	tween.tween_interval(1)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_path))
	

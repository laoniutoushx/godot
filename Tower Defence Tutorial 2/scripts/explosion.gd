extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite3D.play("default")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animated_sprite_3d_animation_finished():
	$AnimatedSprite3D.stop()

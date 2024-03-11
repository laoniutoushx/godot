extends CharacterBody3D


var speed : float
var vel : Vector3
var is_reached = false
var state_machine
enum states {IDLE, WALKING, ATTACKING, MINING, BUILDING}
var current_state = states.IDLE
@onready var animation_tree = $AnimationTree


var team : int = 0
var team_colors : Dictionary = {
	0: preload("res://asserts/material/TeamRedMat.tres"),
	1: preload("res://asserts/material/TeamBlueMat.tres")
}

@onready var selectionRing = $SelectionRing


func _ready():
	state_machine = animation_tree["parameters/playback"]
	speed = 0
	
	if team in team_colors:
		if selectionRing != null:
			selectionRing.material_override = team_colors[team]


const move_speed = 12
# 获取父级导航节点
@onready var navigationAgent = $NavigationAgent3D

	
	
func _physics_process(delta):
	if is_reached:
		pass
	else:

		# 移动点
		var targetPos  = navigationAgent.get_next_path_position()
		# 移动方向
		var direction = global_position.direction_to(targetPos)
		var pos = get_global_transform().origin
		var n = $RayCast3D.get_collision_normal()
		if n.length_squared() < 0.001:
			n = Vector3(0, 1, 0)
			
		vel = (targetPos - pos).slide(n).normalized() * speed
		$Rig.rotation.y = lerp_angle($Rig.rotation.y, atan2(vel.x, vel.z), delta * 10)
		# navigationAgent.velocity = vel
		
		velocity = direction * speed
		
		move_and_slide()
	
	#if(navigationAgent.is_navigation_finished()):
	#	return
	#else:
	#	# 移动点
	#	var targetPos  = navigationAgent.get_next_path_position()
	#	# 移动方向
	#	var direction = global_position.direction_to(targetPos)
	#	# 速度
	#	velocity = direction * move_speed
	#	move_and_slide()


func select():
	$SelectionRing.show()
	
func deselect():
	$SelectionRing.hide()


func change_state(state):
	match(state):
		"idle":
			current_state = states.IDLE
			speed = 0.000001
			state_machine.travel("Idle")
		"walking":
			current_state = states.WALKING
			state_machine.travel("Walk")	
			speed = 2
		
		
		
func move_to(target_pos):
	is_reached = false
	change_state("walking")		
	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().get_navigation_map(), target_pos)
	navigationAgent.target_position = closest_pos
			


	


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	self.velocity = safe_velocity


func _on_navigation_agent_3d_target_reached():
	print("reached")
	change_state("idle")
	is_reached = true
	
	

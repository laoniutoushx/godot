extends CharacterBody3D

@onready var navigationAgent := $NavigationAgent3D
var SPEED = 5
const SMOOTH_SPEED = 5

var lastTargetPos
var lastDirection
var lastRotationY = 0
var lastRotationRadY = 0

var IS_MOVEING = false


func _ready():
	pass
	
	


func _process(delta):
	
		
	
	if(navigationAgent.is_navigation_finished()):
		
		#if(!is_equal_approx(rotation.y, lastRotationY)):	# 判断 lerp_angle 插值旋转是否到达指定角度
		if(((lastRotationY + absf(lastRotationRadY)) <= rotation.y) && lastDirection != null):	# 判断 lerp_angle 插值旋转是否到达指定角度	
			# 判断 lerp_angle 插值旋转是否到达指定角度
			rotateToPoint(delta, SMOOTH_SPEED)
		
		return
	else:
		moveToPoint(delta, SPEED)
		rotateToPoint(delta, SMOOTH_SPEED)
	
	pass	
	
		

func moveToPoint(delta, speed):
	var targetPos  = navigationAgent.get_next_path_position()
	# 移动点
	lastTargetPos = targetPos
	var direction = global_position.direction_to(targetPos)
	# 移动方向
	lastDirection = direction
	# 旋转角度
	lastRotationY = atan2(-lastDirection.x, -lastDirection.z)
	

	
	# 渲染移动路径
	IS_MOVEING = true
	
	
	# 另一种赋值速度的移动方式
	# var new_velocity = direction * speed
	# navigationAgent.set_velocity_forced(new_velocity)
	
	
	velocity = direction * speed
	move_and_slide()
	
	
# TODO 平滑旋转（不是立即旋转）		
func rotateToPoint(delta, speed):
	# 插值旋转（依据转动角度插值，越到后期转动越慢）  (from, to, weight)
	#lastRotationY = atan2(-lastDirection.x, -lastDirection.z)
	#rotation.y = lerp_angle(rotation.y, lastRotationY, delta * SMOOTH_SPEED)
	
	
	# 常量转动（匀速转动）
	var front = transform.basis.z
	var ang = Vector2(front.x, front.z).angle_to(Vector2(lastDirection.x, lastDirection.z))
	var s = sign(ang)
	
	if(rad_to_deg(ang) <= 179): # Creating a threshold otherwise there is a slight vibration
		rotate_y(speed*delta*s)
		lastRotationRadY = speed*delta*s

	#lastRotationRadY = speed * delta * s
	#rotate_y(lastRotationRadY)
	
	
	# 立即转向 Vector3.UP => (0, 1, 0)
	#look_at(Vector3(lastTargetPos.x, global_position.y, lastTargetPos.z), Vector3.UP)
	
	print(front,", ", lastDirection,", ", lastTargetPos, ", ", rotation.y, " | ", lastRotationY + absf(lastRotationRadY))


func _input(event):
	if Input.is_action_just_pressed("LeftMouse"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mousePos = get_viewport().get_mouse_position()
		
		# 显示 mousePos
		showMousePos(mousePos)
		
		var rayLength = 100
		
		# raycast origin
		var origin = camera.project_ray_origin(mousePos)
		var end = origin + camera.project_ray_normal(mousePos) * rayLength
		
		var space_state = get_world_3d().direct_space_state
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		print(result)
		
		navigationAgent.target_position = result.position



func showMousePos(mousePos):
	return
	
	


func _on_navigation_agent_3d_target_reached():
	print(" in range ")



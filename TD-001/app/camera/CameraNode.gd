extends Node3D


const MOVE_MARGIN = 20	# 鼠标靠近边缘的像素距离
const MOVE_SPEED = 30	# 调整相机速度

var zoom_speed = 1.0  # 调整这个值以控制缩放速度
var target_fov = 70.0  # 初始FOV，根据你的需求设置
const ray_length = 1000
@onready var cam = $Camera

# 专门配置相机移动范围（防止超出地图边界）
var map_bounds = Rect2(0, 0, 60, 60)



func _input(event):
	# 鼠标滚轮事件
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			print("Wheel up")
			target_fov = clamp(target_fov - zoom_speed, 20.0, 120.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			print("Wheel down")	
			target_fov = clamp(target_fov + zoom_speed, 20.0, 120.0)

	


# 镜头移动
func calc_move(m_pos, delta):
	var v_size = get_viewport().size
	var move_vec = Vector3(0, 0, 0)
	var camera_pos = position
	
	# 向左、向上移动屏幕
	if m_pos.x < MOVE_MARGIN and camera_pos.x > map_bounds.position.x:
		move_vec.x -= 1
	if m_pos.y < MOVE_MARGIN and camera_pos.z > map_bounds.position.y:
		move_vec.z -= 1
		
	
	# 向右、向下移动屏幕
	if m_pos.x > v_size.x - MOVE_MARGIN and camera_pos.x < map_bounds.end.x:
		# TODO 处理边界值
		move_vec.x += 1
	if m_pos.y > v_size.y - MOVE_MARGIN and camera_pos.z < map_bounds.end.y:
		# TODO 处理边界值
		move_vec.z += 1
		
	#print(m_pos, camera_pos, map_bounds.position.x, map_bounds.position.y, map_bounds.end.x, map_bounds.end.y)	# (1, 1, 0)  or (0, 1, 1)  xyz
	
	# TODO 确保相机在地图边界内
	
	#if camera_pos.x > map_bounds.position.x and camera_pos.x < map_bounds.end.x and camera_pos.z > map_bounds.position.y and camera_pos.z < map_bounds.end.y:
	global_translate(move_vec * get_process_delta_time() * MOVE_SPEED)
		
	
	
	# camera_pos.x = clamp(camera_pos.x, map_bounds.position.x, map_bounds.end.x - v_size.x)
	# camera_pos.z = clamp(camera_pos.z, map_bounds.position.y, map_bounds.end.y - v_size.y)
	
	# global_translate(move_vec * get_process_delta_time() * MOVE_SPEED)
	
	


func move_all_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)	
	if result:
		var collision_point = result.position
		get_tree().call_group("units", "move_to", collision_point)

		
	

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask, [])
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos, delta)
	
	# 单位移动
	#if Input.is_action_just_pressed("main_commond"):
	#	move_all_units(m_pos)
		
	# 镜头景深调整
	# 使用线性插值（lerp）平滑地调整当前FOV到目标FOV
	var current_fov = lerp(cam.get_fov(), target_fov, 0.2)
	# 应用新的FOV值
	cam.set_fov(current_fov)
	
	
	

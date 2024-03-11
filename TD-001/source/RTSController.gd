extends Node3D

@onready var cam  = $"../CameraNode/Camera"
const Constants = preload("res://source/Constants.gd")

var team : int = 0
var old_selected_units : Array = []
var selected_units : Array = []
var start_sel_pos = Vector2()
var m_pos := Vector2()


func _input(event):
	# 鼠标滚轮事件
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Left button was clicked at ", event.position)
			start_sel_pos = m_pos
			print(m_pos)
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			print("select units")
			select_units()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	m_pos = get_viewport().get_mouse_position()

	if Input.is_action_just_pressed("main_commond"):
		move_selected_units()


func raycast_from_mouse(collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)

	var ray_end = ray_start + cam.project_ray_normal(m_pos) * Constants.RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask, [])
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)
	
func get_unit_under_mouse():
	var result_unit = raycast_from_mouse(2)
	if result_unit and "team" in result_unit.collider and result_unit.collider.team == team:
		var selected_unit = result_unit.collider
		return selected_unit
			
func select_units():
	var main_unit = get_unit_under_mouse()
	if selected_units.size() != 0:
		old_selected_units = selected_units
	selected_units = []
	
	# 鼠标移动距离小于 16，认为点选单位
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		if main_unit != null:
			selected_units.append(main_unit)
			
	if selected_units.size() != 0:
		clean_current_units_and_apply_new(selected_units)
	elif selected_units.size() == 0:
		selected_units = old_selected_units
		
func clean_current_units_and_apply_new(new_units):
	for unit in get_tree().get_nodes_in_group("units"):
		unit.deselect()
	for unit in new_units:
		unit.select()
	
	
func move_selected_units():
	var result = raycast_from_mouse(0b100111)
	if selected_units.size() != 0:
		var first_unit = selected_units[0]
		if result.collider.is_in_group("surface"):
			first_unit.move_to(result.position)
			
			

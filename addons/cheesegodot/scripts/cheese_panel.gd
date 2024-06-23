@tool
extends Control

var zoom_level : float = 1.0
var display_is_being_moved : bool = false
var previous_mouse_position : Vector2


func _ready():
	if get_node_or_null("zoom_display") != null:
		get_node("zoom_display").text = str(snapped(zoom_level, 0.05))
	previous_mouse_position = get_global_mouse_position()


func _process(_delta):
	if visible && mouse_is_overlapping():
		$background.size = size
		if display_is_being_moved:
			$displayed_content.position += get_global_mouse_position() - previous_mouse_position
		$displayed_content.scale = Vector2(zoom_level, zoom_level)
		
		var offset_from_origin : Vector2 = $displayed_content.global_position - global_position
		var tile_size : float = 16 * zoom_level
		var tile_offset : Vector2 = Vector2(fmod($displayed_content.position.x, tile_size), fmod($displayed_content.position.y, tile_size))
		$displayed_content/grid.position = (-offset_from_origin * 1.0 / zoom_level + tile_offset / zoom_level) - Vector2(16, 16)
		$displayed_content/grid.size = (size * 1 / zoom_level) + Vector2(32, 32)
		
	else:
		display_is_being_moved = false
	previous_mouse_position = get_global_mouse_position()


func _input(event):
	if visible && mouse_is_overlapping():
		if event is InputEventKey:
			if OS.get_keycode_string(event.physical_keycode) == "R":
				reset_to_default()
		elif event is InputEventMouseButton:
			grab_focus()
			zoom(event)
			move_display(event)


func zoom(event : InputEventMouseButton):
	# check for mouse wheel...
	if event.button_index == 4: # ...up
		zoom_level = clamp(zoom_level + 0.1, 0.4, 10.0)
	elif event.button_index == 5: # ...down
		zoom_level = clamp(zoom_level - 0.1, 0.4, 10.0)
	$zoom_display.text = str(snapped(zoom_level, 0.05))


func move_display(event : InputEventMouseButton):
	# check for middle mouse button
	if event.button_index == 3:
		if event.pressed:
			display_is_being_moved = true
		else:
			display_is_being_moved = false


func reset_to_default():
	zoom_level = 1.0
	$zoom_display.text = "1"
	$displayed_content.position = Vector2(0, 0)


func mouse_is_overlapping():
	var result : bool = true
	
	var pos : Vector2 = global_position
	if get_global_mouse_position().x < pos.x:
		result = false
	elif get_global_mouse_position().y < pos.y:
		result = false
	elif get_global_mouse_position().x > pos.x + size.x:
		result = false
	elif get_global_mouse_position().y > pos.y + size.y:
		result = false
	
	return result

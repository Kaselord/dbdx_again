@tool
extends Control

var zoom_level : float = 1.0
var display_is_being_moved : bool = false
var previous_mouse_position : Vector2
var is_drawing : bool = false
var start_pos_drawing : Vector2
var start_pos_erasing : Vector2
# 0 - pencil; 1 - rectangle
var draw_mode : int = 0
var tile_to_draw : int
var selected_tile_indices = [Vector2i(0, 0), Vector2i(0, 0)]
var selecting_tile : bool = false
var atlas_texture_path : String = ""
var tileset_path : String = ""
var init_update : bool = false
var has_saved : bool = true
# stuff that still needs to be done:
# support for placing level elements


func _ready():
	if get_node_or_null("zoom_display") != null:
		get_node("zoom_display").text = str(snapped(zoom_level, 0.05))
	previous_mouse_position = get_global_mouse_position()


func _process(delta):
	if visible && mouse_is_overlapping():
		if !init_update:
			init_update = true
			refresh()
			reset_to_default()
		$background.size = size
		if display_is_being_moved:
			$displayed_content.position += get_global_mouse_position() - previous_mouse_position
		$displayed_content.scale = Vector2(zoom_level, zoom_level)
		
		var offset_from_origin : Vector2 = $displayed_content.global_position - global_position
		var tile_size : float = 16 * zoom_level
		var tile_offset : Vector2 = Vector2(fmod($displayed_content.position.x, tile_size), fmod($displayed_content.position.y, tile_size))
		$displayed_content/grid.position = (-offset_from_origin * 1.0 / zoom_level + tile_offset / zoom_level) - Vector2(16, 16)
		$displayed_content/grid.size = (size * 1 / zoom_level) + Vector2(32, 32)
		
		if is_drawing:
			draw_tiles()
			show_rect_drawing(tile_size)
			
		else:
			$rect_draw_display.hide()
		
		var mouse_offset : Vector2 = get_global_mouse_position() - $displayed_content.global_position
		var real_indicator_pos : Vector2 = (mouse_offset - Vector2(8, 8) * zoom_level) / zoom_level
		$displayed_content/tile_indicator.position = Vector2(snapped(real_indicator_pos.x, 16), snapped(real_indicator_pos.y, 16))
		
		$displayed_content/screen_indicator.position = Vector2(0, 0)
		
		if selecting_tile:
			$tile_selection/selection_index.rotation += TAU * delta
			var mouse_relative_to_tile_index = get_global_mouse_position() - $tile_selection.global_position
			var scaler : float = 4.0
			var snapped_tile = Vector2(mouse_relative_to_tile_index) + Vector2(8*scaler, 8*scaler)
			snapped_tile.x = clamp(snapped_tile.x, 8*scaler, 254*scaler)
			snapped_tile.y = clamp(snapped_tile.y, 8*scaler, 254*scaler)
			snapped_tile.x = snapped(snapped_tile.x, 16*scaler)
			snapped_tile.y = snapped(snapped_tile.y, 16*scaler)
			$tile_selection/selection_index.position = snapped_tile - Vector2(1, 1) * 8 * scaler
			selected_tile_indices[0] = snapped_tile / 256*scaler - Vector2(1, 1)
		
	else:
		display_is_being_moved = false
		is_drawing = false
		selecting_tile = false
		$tile_selection.hide()
	previous_mouse_position = get_global_mouse_position()
	
	if has_saved:
		name = "CheeseEditor"
	else:
		name = "CheeseEditor(*)"


func _input(event):
	if visible && mouse_is_overlapping():
		if event is InputEventKey:
			if OS.get_keycode_string(event.physical_keycode) == "R":
				reset_to_default()
			if OS.get_keycode_string(event.physical_keycode) == "S":
				save()
			select_tile_input(event)
			switch_draw_mode(event)
		elif event is InputEventMouseButton:
			grab_focus()
			refresh()
			zoom(event)
			editor_drawing_input(event)
			move_display(event)


func save():
	# expand this to actually save stuff to a .tscn
	has_saved = true


func select_tile_input(event : InputEventKey):
	if OS.get_keycode_string(event.physical_keycode) == "T":
		if event.pressed:
			selecting_tile = true
			$tile_selection.show()
		else:
			selecting_tile = false
			$tile_selection.hide()


func get_config():
	var file = FileAccess.open("res://addons/cheesegodot/config.json", FileAccess.READ)
	var dictionary_values = str_to_var(file.get_as_text())
	file.close()
	return dictionary_values


func show_rect_drawing(tile_size : float):
	if draw_mode == 1:
		$rect_draw_display.show()
		var start_point : Vector2 = convert_global_to_tile(start_pos_drawing)
		start_point = convert_tile_to_global(start_point) - global_position
		var end_point : Vector2 = convert_global_to_tile(get_global_mouse_position())
		end_point = convert_tile_to_global(end_point) - global_position
		start_point.x += sign(start_point.x - end_point.x) * tile_size * 0.5
		start_point.y += sign(start_point.y - end_point.y) * tile_size * 0.5
		end_point.x += sign(end_point.x - start_point.x) * tile_size * 0.5
		end_point.y += sign(end_point.y - start_point.y) * tile_size * 0.5
		$rect_draw_display.position = Vector2(0, 0)
		$rect_draw_display.polygon[0] = start_point
		$rect_draw_display.polygon[1] = Vector2(start_point.x, end_point.y)
		$rect_draw_display.polygon[2] = end_point
		$rect_draw_display.polygon[3] = Vector2(end_point.x, start_point.y)


func switch_draw_mode(event : InputEventKey):
	if event.pressed:
		if OS.get_keycode_string(event.physical_keycode) == "1":
			draw_mode = 0
			$draw_mode.text = "Brush"
		elif OS.get_keycode_string(event.physical_keycode) == "2":
			draw_mode = 1
			$draw_mode.text = "Rectangle"


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
	refresh()


func refresh():
	var config : Dictionary = get_config()
	$background.color = Color(config["bg_color"])
	$displayed_content/grid.modulate = Color(config["grid_color"])
	if config["path_tile_atlas"] != atlas_texture_path:
		atlas_texture_path = config["path_tile_atlas"]
		var atlas_texture : Texture = load(config["path_tile_atlas"])
		$tile_selection/collision_atlas.texture = atlas_texture
	if config["path_tileset"] != tileset_path:
		tileset_path = config["path_tileset"]
		var used_tileset : TileSet = load(config["path_tileset"])
		$displayed_content/tilemap.tile_set = used_tileset


func editor_drawing_input(event : InputEventMouseButton):
	if event.button_index == 1 or event.button_index == 2:
		if event.pressed:
			is_drawing = true
			start_pos_drawing = get_global_mouse_position()
		else:
			is_drawing = false
			if draw_mode == 1:
				draw_tile_rect(convert_global_to_tile(start_pos_drawing), convert_global_to_tile(get_global_mouse_position()))
	
	if event.button_index == 1:
		tile_to_draw = 0
	elif event.button_index == 2:
		tile_to_draw = -1


func draw_tiles():
	var tilemap : TileMap = get_node_or_null("displayed_content/tilemap")
	if tilemap != null:
		has_saved = false
		if draw_mode == 0:
			if tile_to_draw >= 0:
				tilemap.set_cell(0, convert_global_to_tile(get_global_mouse_position()), tile_to_draw, selected_tile_indices[0])
			else:
				tilemap.erase_cell(0, convert_global_to_tile(get_global_mouse_position()))


func draw_tile_rect(start : Vector2i, finish : Vector2i):
	var tilemap : TileMap = get_node_or_null("displayed_content/tilemap")
	# loop from the top left value to the bottom right value. +1 because for i in range(a, b) will range from a to (b-1)
	if tilemap != null:
		has_saved = false
		for x in range(min(start.x, finish.x), max(start.x, finish.x) + 1):
			for y in range(min(start.y, finish.y), max(start.y, finish.y) + 1):
				if tile_to_draw >= 0:
					tilemap.set_cell(0, Vector2i(x, y), tile_to_draw, selected_tile_indices[0])
				else:
					tilemap.erase_cell(0, Vector2i(x, y))


func convert_global_to_tile(global_coords : Vector2):
	var relative_dst_to_tile_origin : Vector2 = global_coords - $displayed_content/tilemap.global_position
	var tile_size_adjusted : Vector2 = relative_dst_to_tile_origin / (16.0 * zoom_level) - Vector2(0.5, 0.5)
	var snapped_to_int : Vector2i = Vector2i(snapped(tile_size_adjusted.x, 1.0), snapped(tile_size_adjusted.y, 1.0))
	return snapped_to_int


func convert_tile_to_global(tile_coords : Vector2):
	var relative_dst_to_tile_origin : Vector2 = tile_coords * (16.0 * zoom_level) + Vector2(0.5, 0.5)
	var global = relative_dst_to_tile_origin + $displayed_content/tilemap.global_position + Vector2(1, 1) * 8 * zoom_level
	return global


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

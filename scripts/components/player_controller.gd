extends Node
class_name ComponentPlayerController

var x_input : float = 0.0
@export var movement_path : NodePath
var movement : ComponentMovement = null
@export var x_speed : float = 200
@export var acceleration : float = 0.2
@export var jump_force : float = 300
var coyote_buffer : int = 0
var jump_buffer : int = 0
var has_released_jump : bool = false


func _physics_process(_delta):
	if movement == null:
		movement = get_node_or_null(movement_path)
	else:
		movement.velocity.x = lerp(movement.velocity.x, x_input * x_speed, acceleration)


func _process(_delta):
	# signed so no float values occur on a controller or similar input devices
	x_input = sign(Input.get_axis("left", "right"))
	
	if movement != null:
		
		if jump_buffer > 0:
			jump_buffer -= 1
		
		if movement.is_floored:
			coyote_buffer = 8
			if jump_buffer > 0:
				execute_jump()
				jump_buffer = 0
		else:
			if coyote_buffer > 0:
				coyote_buffer -= 1
		
		if Input.is_action_just_pressed("jump"):
			if coyote_buffer > 0:
				execute_jump()
			else:
				jump_buffer = 7
		
		# variable jump height
		if Input.is_action_just_released("jump"):
			if movement.velocity.y < 0 && !has_released_jump:
				movement.velocity.y *= 0.5
				has_released_jump = true


func execute_jump():
	has_released_jump = false
	movement.velocity.y = -jump_force
	movement.is_floored = false

extends Node2D
class_name ComponentMovement

@export var gravity : float = 800
@export var velocity : Vector2 = Vector2(0, 0)
var is_floored : bool = false
var is_sloped : bool = false


func _ready():
	get_parent().add_to_group("moving_thing")


func _physics_process(delta):
	# do the gravity thing
	if velocity.y < gravity:
		velocity.y += gravity * delta
	
	# apply velocity to whatever node the parent is
	if get_parent().get_class() == "CharacterBody2D":
		
		if abs(velocity.x) < 1.0:
			velocity.x = 0.0
		
		var previous_position : Vector2 = get_parent().global_position
		
		get_parent().velocity = velocity
		get_parent().move_and_slide()
		
		slope_handling(previous_position)
		
		if get_parent().is_on_floor():
			velocity.y = 0
			is_floored = true
		else:
			is_floored = false
		
		if get_parent().is_on_ceiling():
			velocity.y = 0
		
	elif get_parent() is Node2D:
		
		get_parent().position += velocity * delta


func slope_handling(prev_pos : Vector2): # please rework to use characterbody's inbuild slope functions!
	# on floor in current and previous frame?
	if get_parent().is_on_floor() && is_floored:
		var diff_to_last_frame : Vector2 =  get_parent().global_position - prev_pos
		# jitter prevention
		if abs(diff_to_last_frame.y) > 1:
			get_parent().position.y += diff_to_last_frame.y * abs(sign(velocity.x))
		
		# are you standing still?
		if abs(velocity.x) < 1:
			# coefficient to account for gravity
			get_parent().position -= diff_to_last_frame

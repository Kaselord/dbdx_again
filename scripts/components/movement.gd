extends Node2D
class_name ComponentMovement

@export var gravity : float = 800
@export var velocity : Vector2 = Vector2(0, 0)
var is_floored : bool = false
var is_sloped : bool = false


func _physics_process(delta):
	# do the gravity thing
	if velocity.y < gravity:
		velocity.y += gravity * delta
	
	# apply velocity to whatever node the parent is
	if get_parent().get_class() == "CharacterBody2D":
		
		get_parent().velocity = velocity
		get_parent().move_and_slide()
		
		if get_parent().is_on_floor():
			velocity.y = 0
			is_floored = true
		else:
			is_floored = false
		
	elif get_parent() is Node2D:
		
		get_parent().position += velocity * delta

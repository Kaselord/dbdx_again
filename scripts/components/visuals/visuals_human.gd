extends Node2D

@export var movement_path : NodePath
var movement : ComponentMovement = null
var direction : float = 1.0


func _physics_process(_delta):
	if movement == null:
		movement = get_node_or_null(movement_path)
	else:
		if movement.velocity.x != 0:
			direction = sign(movement.velocity.x)
			var head_strands : Node2D = get_node("head/strands")
			head_strands.position.x = lerp(head_strands.position.x, sign(movement.velocity.x), 0.2)
			
			var hair : Line2D = get_node("hair")
			hair.position.x = -head_strands.position.x
			
			get_node("leg_left").direction = direction
			get_node("leg_right").direction = direction

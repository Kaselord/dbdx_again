extends Camera2D

@export var thing_to_follow_path : NodePath
var thing_to_follow : Node2D = null
@export var interpolation : float = 0.1
@export var velocity_weight : Vector2 = Vector2(0.3, 0.1)


func _physics_process(_delta):
	if thing_to_follow != null:
		var velocity_adder : Vector2 = Vector2(0, 0)
		if thing_to_follow.is_in_group("moving_thing"):
			var movement_node : Node2D = thing_to_follow.get_node("movement")
			velocity_adder = movement_node.velocity * velocity_weight
			velocity_adder.x = clamp(velocity_adder.x, -320, 320)
			velocity_adder.y = clamp(velocity_adder.y, -192, 192)
		position = lerp(position, thing_to_follow.position + velocity_adder, interpolation)
	else:
		thing_to_follow = get_node_or_null(thing_to_follow_path)
		

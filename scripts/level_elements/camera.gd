extends Camera2D

@export var thing_to_follow_path : NodePath
var thing_to_follow : Node2D = null
@export var interpolation : float = 0.1
@export var velocity_weight : Vector2 = Vector2(0.3, 0.1)


func _physics_process(_delta):
	if thing_to_follow != null:
		position = thing_to_follow.position
		position.x = snapped(position.x - 320, 640)
		position.y = snapped(position.y - 192, 384)
	else:
		thing_to_follow = get_node_or_null(thing_to_follow_path)

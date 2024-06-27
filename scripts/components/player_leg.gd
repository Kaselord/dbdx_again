extends Line2D

var last_snap_point : Vector2 = Vector2(0, 0)
var floor_ray : RayCast2D = null
var direction : float = 1.0
var prev_pos : Vector2 = Vector2(0, 0)


func _physics_process(_delta):
	if floor_ray != null:
		
		floor_ray.rotation_degrees += direction * position.x * (prev_pos.x - global_position.x) * 2
		if abs(floor_ray.rotation_degrees) > 45:
			floor_ray.rotation_degrees = -sign(floor_ray.rotation_degrees) * 45
		
		# is the raycast colliding?
		if floor_ray.is_colliding() && floor_ray.get_collider().get_class() == "TileMap":
			
			#if last_snap_point.distance_squared_to(global_position) > 64:
			last_snap_point = floor_ray.get_collision_point()
			
			points[2] = lerp(points[2], last_snap_point - global_position, 0.5)
			points[1] = (points[2] - points[0]).normalized()
			
		elif !floor_ray.is_colliding():
			
			points[2] = lerp(points[2], Vector2(-direction * 2, 6), 0.3)
			points[1] = lerp(points[1], Vector2(direction * 3, 2), 0.3)
		
	else:
		floor_ray = get_node_or_null("floor_ray")
	
	prev_pos = global_position

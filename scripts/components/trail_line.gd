extends Line2D
class_name ComponentTrailLine

var prev_pos : Vector2 = Vector2(0, 0)
var time : float = 0.0


func _ready():
	prev_pos = global_position


func _physics_process(delta):
	var prev_point_pos : Vector2 = Vector2(0, 0)
	for idx in get_point_count() - 1:
		
		points[idx + 1] += prev_pos - global_position
		points[idx + 1].y += 60.0 * delta
		points[idx + 1].x += sin(time * 6 + idx * 0.4) * 0.1
		points[idx + 1] = prev_point_pos + (points[idx + 1] - prev_point_pos).normalized() * 2
		
		prev_point_pos = points[idx + 1]
	
	prev_pos = global_position
	time += delta

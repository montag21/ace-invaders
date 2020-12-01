extends Area2D

const SPEED = 250
export var direction = Vector2(-1, 0) * SPEED

func _ready():
	add_to_group("BULLETS")
	connect("area_entered", self, "_on_hit")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func _on_hit(_target_area):
	die()
	
func _on_screen_exited():
	die()

func die():
	remove_from_group("BULLETS")
	queue_free()

func _physics_process(delta):
	position += direction * delta

func set_direction(dir: Vector2):
	direction = dir * SPEED

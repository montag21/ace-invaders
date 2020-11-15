extends Node2D

const SPEED = 250
export var direction = Vector2(-1, 0) * SPEED

onready var body = get_node("KinematicBody2D")

func _ready():
	add_to_group("BULLETS")
	body.get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")

func _on_screen_exited():
	remove_from_group("BULLETS")
	queue_free()

func _physics_process(delta):
	var collision = body.move_and_collide(direction * delta)
	if collision != null && collision.collider != null:
		collision.collider.call_deferred("bullet_hit", collision.position, collision.normal)
		queue_free()
	

func set_direction(dir: Vector2):
	direction = dir * SPEED

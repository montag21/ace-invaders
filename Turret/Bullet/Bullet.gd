extends Node2D

const SPEED = 200
export var direction = Vector2(-1, 0) * SPEED

onready var body = get_node("KinematicBody2D")

func _ready():
	add_to_group("BULLETS")
	body.get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")

func _on_screen_exited():
	remove_from_group("BULLETS")
	queue_free()

func _physics_process(delta):
	var _collision = body.move_and_collide(direction * delta)

func set_direction(dir: Vector2):
	direction = dir * SPEED

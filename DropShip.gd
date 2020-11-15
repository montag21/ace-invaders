extends RigidBody2D

const STACHE_GUY_REGULAR = preload("res://StachedGuyRegular.tscn")
onready var castle_node = get_parent().get_node("Background/Castle")
onready var destination = castle_node.position.x

var speed = 200
var gravity = 800
var velocity = Vector2()
var spawn_count = 3

func _ready():
	add_to_group("SHIPS")
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta):
	velocity.y += gravity * delta

func _on_screen_exited():
	print_debug("Instance exited screen!")
	remove_from_group("SHIPS")
	queue_free()


func _on_GroundDetector_body_entered(body):
	if body.name == "Land":
		for n in spawn_count:
			var instance = STACHE_GUY_REGULAR.instance()
			instance.position.y = position.y
			if destination > position.x:
				instance.position.x = position.x + 30
			else:
				instance.position.x = position.x - 30
			get_parent().add_child(instance)
			yield(get_tree().create_timer(.5), "timeout")

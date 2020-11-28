extends RigidBody2D

const EXPLOSION = preload("res://Explosion/Explosion.tscn")
const STACHE_GUY_REGULAR = preload("res://Stacheling/Stacheling.tscn")
onready var castle_node = get_parent().get_node("Background/Castle")
onready var destination = castle_node.position.x
var spawn_count = 5

func _ready():
	add_to_group("SHIPS")
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	connect("body_entered", self, "_on_hit")

func _on_screen_exited():
	die()
	
func die():
	set_physics_process(false)
	$Sprite.hide()
	remove_from_group("SHIPS")
	var explosion = EXPLOSION.instance()
	get_parent().add_child(explosion)
	explosion.trigger(position, 1)
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

func rocket_hit():
	die()

func _process(delta):
	if $RayCast2D.is_colliding():
		var origin = $RayCast2D.global_transform.origin
		var collision_point = $RayCast2D.get_collision_point()
		var distance = origin.distance_to(collision_point)
		if distance > 50:
			linear_velocity = Vector2(0, distance)
		if distance > 1:
			$Exhaust.emitting = true
		else: $Exhaust.emitting = false

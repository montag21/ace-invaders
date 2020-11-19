extends Area2D

export var start_speed: = 50
export var max_speed = 250
export var steer_force = 100

const EXPLOSION = preload("res://Explosion/Explosion.tscn")
var target = null
var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready():
	add_to_group("BULLETS")
	connect("body_entered", self, "_on_hit")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func start(_target):
	target = _target
	velocity = Vector2(cos(rotation), sin(rotation)) * start_speed
	
func _on_screen_exited():
	die(false)
	
func _on_hit(_target):
	get_node(_target.get_path()).call_deferred("rocket_hit")
	die()
	
func die(explode = true):
	$Particles2D.hide()
	$Particles2D.emitting = false
	$Body.hide()
	set_physics_process(false)
	remove_from_group("BULLETS")
	if explode:
		var explosion = EXPLOSION.instance()
		get_parent().add_child(explosion)
		explosion.trigger(position, 0.3)
	queue_free()
	
func seek():
	var steer = velocity
	if target:
		var desired = (target.global_position - global_position).normalized() * max_speed
		steer = (desired - velocity).normalized() * steer_force
	return steer
	
func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(max_speed)
	rotation = velocity.angle()
	position += velocity * delta

func set_target(tgt):
	target = tgt

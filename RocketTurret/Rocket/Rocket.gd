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
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
	connect("area_entered", self, "_on_target_hit")

func start(_target):
	$AudioStreamPlayer2D.play()
	target = _target
	velocity = Vector2(cos(rotation), sin(rotation)) * start_speed
	
func _on_screen_exited():
	call_deferred("die", false)

func _on_target_hit(_target_area):
	call_deferred("die")
	
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
		$AudioStreamPlayer2D.stop()
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

extends RigidBody2D

enum State { Entry, Orbit, Land }

const EXPLOSION = preload("res://Explosion/Explosion.tscn")
const STACHE_GUY_REGULAR = preload("res://Stacheling/Stacheling.tscn")
onready var destination = GameManager.stacheling_target.x
const orbit_speed = 200
const initial_velocity = Vector2(1.0, 0.75) * orbit_speed * 4
var exhaust_on = false

var spawn_count = 3
var state = State.Entry setget set_state

var velocity
var orbit_height
var descent

func _ready():
	GameManager.connect("game_phase_changed", self, "_on_game_phase_changed")
	add_to_group("SHIPS")
	connect("body_entered", self, "_on_body_entered")
	$ProjectileTracker.connect("area_entered", self, "_on_projectile_hit")
	set_state(State.Entry)

func _on_screen_exited():
	die()

func _on_screen_exited_orbit():
	position = Vector2(0, position.y)

func set_state(_state):
	state = _state
	match _state:
		State.Entry:
			mode = RigidBody2D.MODE_KINEMATIC
			$VisibilityNotifier2D.disconnect("screen_exited", self, "_on_screen_exited")
		State.Orbit:
			mode = RigidBody2D.MODE_KINEMATIC
			$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited_orbit")
		State.Land:
			linear_velocity = Vector2.ZERO
			mode = RigidBody2D.MODE_RIGID
			$VisibilityNotifier2D.disconnect("screen_exited", self, "_on_screen_exited_orbit")
			$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func start_entry(_start_position, _orbit_height):
	position = _start_position
	orbit_height = _orbit_height
	velocity = initial_velocity
	descent = abs(orbit_height - _start_position.y)

func _process(delta):
	match state:
		State.Entry:
			position += velocity * delta
			var orbit_delta = (position.y - orbit_height + descent)/descent
			velocity = initial_velocity.linear_interpolate(Vector2.RIGHT * orbit_speed,  orbit_delta)
			if position.y >= orbit_height - 1:
				set_state(State.Orbit)
		State.Orbit:
			position += Vector2.RIGHT * orbit_speed * delta
			
	# Landing logic
	if $RayCast2D.is_colliding():
		var origin = $RayCast2D.global_transform.origin
		var collision_point = $RayCast2D.get_collision_point()
		var distance = origin.distance_to(collision_point)
		linear_velocity = Vector2(0, distance)
		if $Exhaust.emitting == false:
			$Exhaust.emitting = true
			exhaust_on = true
			$AudioStreamPlayer2D.play()
		if distance <= 30:
			$Exhaust.emitting = false
			exhaust_on = false
			$AudioStreamPlayer2D.stop()

func die():
	set_physics_process(false)
	$Sprite.hide()
	remove_from_group("SHIPS")
	var explosion = EXPLOSION.instance()
	get_parent().call_deferred("add_child", explosion)
	explosion.trigger(position, 1)
	queue_free()

func _on_game_phase_changed(_current_phase):
	match _current_phase:
		GameManager.GamePhase.LandingStart:
			set_state(State.Land)	

func _on_body_entered(body):
	if body.name == "Land":
		mode = RigidBody2D.MODE_KINEMATIC
		spawn_stachelings()

func _on_projectile_hit(_projectile_area):
	die()

func spawn_stachelings():
	for n in spawn_count:
		var instance = STACHE_GUY_REGULAR.instance()
		instance.destination = destination
		instance.position.y = position.y
		if destination > position.x:
			instance.position.x = position.x + 30
		else:
			instance.position.x = position.x - 30
		get_parent().add_child(instance)
		yield(get_tree().create_timer(.5), "timeout")

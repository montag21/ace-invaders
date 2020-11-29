extends RigidBody2D

enum State { Entry, Orbit, Land }

const EXPLOSION = preload("res://Explosion/Explosion.tscn")
const STACHE_GUY_REGULAR = preload("res://Stacheling/Stacheling.tscn")
onready var destination = GameManager.stacheling_target.x
const orbit_speed = 200

var spawn_count = 5
var state = State.Entry setget set_state

var velocity
var orbit_height

func _ready():
	GameManager.connect("game_phase_changed", self, "_on_game_phase_changed")
	add_to_group("SHIPS")
	connect("body_entered", self, "_on_hit")
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
	velocity = Vector2(1, 0.75) * orbit_speed * 3

func _physics_process(delta):
	match state:
		State.Entry:
			position += velocity * delta
			var orbit_delta = max(abs(orbit_height - position.y), 1)
			velocity = velocity.linear_interpolate(Vector2.RIGHT * orbit_speed,  1/orbit_delta)
			if orbit_delta == 1:
				set_state(State.Orbit)
		State.Orbit:
			position += Vector2.RIGHT * orbit_speed * delta

func die():
	set_physics_process(false)
	$Sprite.hide()
	remove_from_group("SHIPS")
	var explosion = EXPLOSION.instance()
	get_parent().add_child(explosion)
	explosion.trigger(position, 1)
	queue_free()

func _on_game_phase_changed(_current_phase):
	match _current_phase:
		GameManager.GamePhase.LandingStart:
			set_state(State.Land)

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

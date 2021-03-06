extends StaticBody2D

enum State {SCAN, ATTACK}
enum Direction { Left, Right }

const BULLET = preload("res://Turret/Bullet/Bullet.tscn")
const ROTATION_SPEED = 0.7
const ATTACK_ROTATION_BOOST = 5
export(Direction) var DIRECTION = Direction.Left setget set_direction
export var MIN_ANGLE: float = -0.25
export var MAX_ANGLE: float = 1
const RANGE = 200
export var recharge_rate = 0.5
const TARGET_MASK = 0b00000000000000001000
var rotation_direction = 1

var shoot_cooldown: float = 0
var state
var target

onready var turret_head = get_node("Head")

func _ready():
	turret_head.rotation = MIN_ANGLE
	setstate(State.SCAN)

func set_direction(_direction):
	var should_flip = _direction == Direction.Right
	$Base.flip_h = should_flip
	$Head.flip_h = should_flip
	DIRECTION = _direction

func setstate(new_state):
	state = new_state

func _physics_process(delta):
	match state:
		State.SCAN:
			update_scan_position(delta)
		State.ATTACK:
			shoot(delta)
			update_attack_position(delta)

func update_scan_direction():
	if turret_head.rotation >= MAX_ANGLE:
		rotation_direction = -1
	elif turret_head.rotation <= MIN_ANGLE:
		rotation_direction = 1

func update_scan_position(delta):
	var distance_to_edge = 2 * min(turret_head.rotation - MIN_ANGLE, MAX_ANGLE - turret_head.rotation)/abs(MAX_ANGLE - MIN_ANGLE)
	var rotation_speed = lerp(ROTATION_SPEED/3, ROTATION_SPEED, distance_to_edge)
	turret_head.rotate(rotation_direction * rotation_speed * rand_range(1.0, 1.5) * delta)
	update_scan_direction()
	raycast()

func get_turret_rotation():
	var _turret_head_rotation = turret_head.rotation
	if DIRECTION == Direction.Right:
		if _turret_head_rotation > PI:
			_turret_head_rotation = PI - _turret_head_rotation
		else:
			_turret_head_rotation = PI + _turret_head_rotation
	return _turret_head_rotation

func raycast():

	var space_state = get_world_2d().direct_space_state
	var target_position = turret_head.global_position - polar2cartesian(RANGE, get_turret_rotation())
	var result = space_state.intersect_ray(turret_head.global_position, target_position, [self], TARGET_MASK)
	if !result.empty():
		target = result.collider
		setstate(State.ATTACK)

func get_angle_to_target():
	var vector_towards_target = target.global_position - turret_head.global_position
	var _angle_to_target = atan2(-vector_towards_target.y, -vector_towards_target.x)
	if DIRECTION == Direction.Right:
		if _angle_to_target < 0:
			_angle_to_target = PI + _angle_to_target
		else:
			_angle_to_target = -(PI - _angle_to_target)
	return _angle_to_target

func has_valid_target():
	if target == null:
		return false
	var angle_to_target = get_angle_to_target()
	if angle_to_target < MIN_ANGLE || angle_to_target > MAX_ANGLE:
		target = null
		return false
	return true

func update_attack_position(delta):
	if !has_valid_target():
		setstate(State.SCAN)
		return
	var angle = get_angle_to_target()
	turret_head.rotation = lerp(turret_head.rotation, angle, delta * ROTATION_SPEED * ATTACK_ROTATION_BOOST);

func shoot(delta):
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		spawn_bullet()
		$AudioStreamPlayer2D.play()
		shoot_cooldown = recharge_rate

func spawn_bullet():
	var _turret_rotation = get_turret_rotation()
	var bullet_direction = -Vector2(cos(_turret_rotation), sin(_turret_rotation))
	var bullet = BULLET.instance()
	bullet.position = turret_head.position + bullet_direction * 20
	bullet.set_direction(bullet_direction)
	self.add_child(bullet)

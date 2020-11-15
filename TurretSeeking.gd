extends StaticBody2D

enum State {SCAN, ATTACK}

const ROTATION_SPEED = 1
const ATTACK_ROTATION_BOOST = 10
export var MIN_ANGLE: float = -0.25
export var MAX_ANGLE: float = 1
const RANGE = 200
const RECHARGE_RATE = 100
const TARGET_MASK = 0b00000000000000001000
var rotation_direction = 1

var state
var target
onready var turret_head = get_node("Head")

func _ready():
	setstate(State.SCAN)
	
func setstate(new_state):
	state = new_state
	match new_state:
		State.SCAN:
			turret_head.rotation = clamp(turret_head.rotation, MIN_ANGLE, MAX_ANGLE)

func _physics_process(delta):
	match state:
		State.SCAN:
			update_scan_position(delta)
		State.ATTACK:
			update_attack_position(delta)
			shoot()

func update_scan_rotation():
	if turret_head.rotation >= MAX_ANGLE:
		rotation_direction = -1
	elif turret_head.rotation <= MIN_ANGLE:
		rotation_direction = 1

func update_scan_position(delta):
	turret_head.rotate(rotation_direction * ROTATION_SPEED * delta)
	update_scan_rotation()
	raycast()
	
	
func raycast():
	var space_state = get_world_2d().direct_space_state
	var target_position = global_position - polar2cartesian(RANGE, turret_head.rotation)
	var result = space_state.intersect_ray(global_position, target_position, [self], TARGET_MASK)
	if !result.empty():
		target = result.collider
		setstate(State.ATTACK)
	
func get_angle_to_target():
	var vector_towards_target = target.global_position - self.global_position;
	return PI - abs(atan2(vector_towards_target.y, vector_towards_target.x));
	
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
	
func shoot():
	#shoot a projectile here
	pass

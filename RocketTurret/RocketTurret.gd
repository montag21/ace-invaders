extends Node2D

enum State {IDLE, ATTACK}

export var RECHARGE_RATE = 1.0

const ROCKET = preload("res://RocketTurret/Rocket/Rocket.tscn")
const TARGET_MASK = 0b00000000000000000100
var targets_semaphore = Semaphore.new()

var shoot_cooldown = 0.0
var state
var targets = []

func _ready():
	targets_semaphore.post()
	$Area2D.connect("body_entered", self, "_on_dropship_entered")
	setstate(State.IDLE)
	
func setstate(new_state):
	state = new_state

func _physics_process(delta):
	cleanup_targets()
	match state:
		State.ATTACK:
			shoot(delta)

func shoot(delta):
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		spawn_rocket()
		shoot_cooldown = RECHARGE_RATE
		
func cleanup_targets():
	targets_semaphore.wait()
	for t in targets:
		if t == null:
			targets.erase(t)
	if targets.size() == 0:
		setstate(State.IDLE)
	targets_semaphore.post()

func spawn_rocket():
	targets_semaphore.wait()
	if targets.size() == 0:
		return
	var target = targets[0]
	targets_semaphore.post()
	
	var rocket_direction = -Vector2(cos($Head.rotation), sin($Head.rotation))
	var rocket = ROCKET.instance()
	rocket.position = $Head.position + rocket_direction * 15
	rocket.look_at(rocket.position + rocket_direction * 10)
	rocket.start(target)
	self.add_child(rocket)


func _on_dropship_entered(dropship):
	targets_semaphore.wait()
	targets.push_back(dropship)
	targets_semaphore.post()
	setstate(State.ATTACK)

extends Node

const DROPSHIP_POOL_SIZE = 3
const DROPSHIP_PASSENGERS = 7
const STACHELING_EXIT_COOLDOWN = 0.5
const CASTLE_MAX_HP = 21

enum GamePhase { Launch, LandingPrep, LandingStart, Win, Loss }
signal game_phase_changed
signal game_round_changed
signal castle_hp_changed

const DROP_SHIP = preload("res://DropShip/DropShip.tscn")
const STACHE_GUY_REGULAR = preload("res://Stacheling/Stacheling.tscn")

var current_phase setget set_game_phase
var dropship_pool
var stacheling_destination
var world
var game_state
var game_round
var castle_hp

func _ready():
	game_round = 1
	castle_hp = CASTLE_MAX_HP
	reset()
	
func init_dropship_pool():
	dropship_pool = DROPSHIP_POOL_SIZE
	
func launch_dropship():
	assert(current_phase == GamePhase.Launch && dropship_pool  > 0, "Unable to launch dropship")
	dropship_pool -= 1
	init_dropship()
	if dropship_pool <= 0:
		set_game_phase(GamePhase.LandingPrep)
	
func start_landing():
	set_game_phase(GamePhase.LandingStart)
	
func init_dropship():
	var instance = DROP_SHIP.instance()
	world.add_child(instance)
	instance.connect("die", self, "_on_dropship_die")
	instance.start_entry(Vector2(-10,-10), 250)
		
func reset():
	set_game_phase(GamePhase.Launch)

func set_game_phase(_game_phase):
	current_phase = _game_phase
	match _game_phase:
		GamePhase.Launch:
			init_dropship_pool()
			init_game_state()
	emit_signal("game_phase_changed", _game_phase)
	
func init_game_state():
	game_state = {
		dropships = DROPSHIP_POOL_SIZE,
		stachelings = 0
	}
	
func spawn_stachelings(dropship):
	for n in DROPSHIP_PASSENGERS:
		if dropship == null:
			return
		var position_x = dropship.position.x
		var instance = STACHE_GUY_REGULAR.instance()
		instance.destination = stacheling_destination
		instance.position.y = dropship.position.y
		var backyard = false
		if stacheling_destination > position_x:
			instance.position.x = position_x + 30
		else:
			backyard = true
			instance.position.x = position_x - 30
		world.add_child(instance)
		instance.connect("die", self, "_on_stacheling_died")
		instance.connect("penetrate", self, "_on_stacheling_penetrated", [ backyard ])
		game_state.stachelings += 1
		yield(get_tree().create_timer(STACHELING_EXIT_COOLDOWN), "timeout")
	dropship.call_deferred("die", false)

func _on_stacheling_died():
	game_state.stachelings -= 1
	ScoreManager.track_stacheling_death()
	verify_game_state()
	
func _on_stacheling_penetrated(backyard):
	game_state.stachelings -= 1
	if backyard:
		ScoreManager.track_backyard_penetration()
	else:
		ScoreManager.track_penetration()
	castle_hp -= 1
	emit_signal("castle_hp_changed", castle_hp)
	if castle_hp <= 0:
		get_tree().change_scene("res://Menu/GameOverScreen.tscn")
	verify_game_state()
	
func _on_dropship_die(crash):
	game_state.dropships -= 1
	if crash:
		ScoreManager.track_dropship_crash()
	verify_game_state()
	
func verify_game_state():
	if game_state.stachelings == 0 && game_state.dropships == 0:
		game_round += 1
		emit_signal("game_round_changed", game_round)
		reset()
		print("Round #%d started" % game_round)
	
func init_world(_world, _main_poi):
	world = _world
	stacheling_destination = _main_poi.x
	reset()

extends Node

enum GamePhase { Launch, LandingPrep, LandingStart, Win, Loss }
signal game_phase_changed

const DROP_SHIP = preload("res://DropShip/DropShip.tscn")

var current_phase setget set_game_phase
var dropship_pool
var stacheling_target
var world

func _ready():
	set_game_phase(GamePhase.Launch)
	
func init_dropship_pool():
	dropship_pool = 3
	
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
	instance.start_entry(Vector2(-10,-10), 250)
		
func reset():
	set_game_phase(GamePhase.Launch)

func set_game_phase(_game_phase):
	current_phase = _game_phase
	match _game_phase:
		GamePhase.Launch:
			init_dropship_pool()
	emit_signal("game_phase_changed", _game_phase)
	
func init_world(_world, _main_poi):
	world = _world
	stacheling_target = _main_poi
	reset()

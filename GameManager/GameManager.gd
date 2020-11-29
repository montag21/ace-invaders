extends Node

enum GamePhase { Launch, Landing, Win, Loss }
signal game_phase_changed

var current_phase setget set_game_phase
var dropship_pool setget set_dropship_pool

func _ready():
	set_game_phase(GamePhase.Launch)
	
func reset():
	set_game_phase(GamePhase.Launch)

func set_game_phase(_game_phase):
	current_phase = _game_phase
	match _game_phase:
		GamePhase.Launch:
			dropship_pool = 3
	emit_signal("game_phase_changed", _game_phase)
			
			
func set_dropship_pool(_val):
	dropship_pool = _val
	if dropship_pool <= 0 && current_phase == GamePhase.Launch:
		set_game_phase(GamePhase.Landing)

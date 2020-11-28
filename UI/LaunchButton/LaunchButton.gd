extends Button

func _ready():
	GameState.connect("game_phase_changed", self, "_on_game_phase_changed")

func _on_game_phase_changed(_current_phase):
	match _current_phase:
		GameState.GamePhase.Launch:
			visible = true
			update_text()
		_:
			visible = false

func update_text():
	text = "Launch Dropship (%s left)" % GameState.dropship_pool
	
func _pressed():
	GameState.dropship_pool -= 1
	update_text()

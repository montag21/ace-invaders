extends Button

func _ready():
	GameManager.connect("game_phase_changed", self, "_on_game_phase_changed")

func _on_game_phase_changed(_current_phase):
	match _current_phase:
		GameManager.GamePhase.Launch:
			visible = true
			update_text()
		GameManager.GamePhase.LandingPrep:
			visible = true
			update_text()
		_:
			visible = false

func update_text():
	if GameManager.dropship_pool > 0:
		text = "Launch Dropship (%s left)" % GameManager.dropship_pool
		return
	text = "Land"
	
func _pressed():
	if text == "Land":
		GameManager.start_landing()
		return
	update_text()
	GameManager.launch_dropship()

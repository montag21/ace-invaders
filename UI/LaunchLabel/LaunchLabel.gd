extends Label

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
		text = "Press [SPACE]\nto launch a dropship\n(%s left)" % GameManager.dropship_pool
		return
	text = "Press [SPACE] to land"

func _unhandled_key_input(event):
	if event.is_action_pressed("player_input"):
		if text == "Press [SPACE] to land":
			GameManager.start_landing()
			return
		GameManager.launch_dropship()
		update_text()

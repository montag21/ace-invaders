extends Node


func _ready():
	GameManager.connect("game_round_changed", self, "_on_round_changed")
	ScoreManager.connect("score_changed", self, "_on_score_changed")

func _on_round_changed(game_round):
	$PanelContainer/VBoxContainer/Round.text = "Round: %d" % game_round

func _on_score_changed(score):
	$PanelContainer/VBoxContainer/Score.text = "Score: %d" % score

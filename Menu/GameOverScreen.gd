extends Control


func _ready():
	$"Menu/CenterRow/Buttons/Game Over".text = "BIG WIN!\nYOUR FINAL SCORE IS:\n%d" % ScoreManager.score


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Menu/Intro/GeneralSpeechFirst.tscn")


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Menu/CreditsScreen.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()

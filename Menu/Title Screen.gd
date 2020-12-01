extends Control

func _ready():
	MenuMusic.play()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Menu/Intro/GeneralSpeechFirst.tscn")

func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Menu/CreditsScreen.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

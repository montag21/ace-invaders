extends Control

func _ready():
	$AudioStreamPlayer.play()


func _on_BackButton_pressed():
	get_tree().change_scene("res://Menu/Intro/GeneralSpeechFirst.tscn")


func _on_NextButton_pressed():
	get_tree().change_scene("res://Menu/Intro/GeneralSpeechFinal.tscn")

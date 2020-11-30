extends Control

func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state


func _on_ContunueButton_pressed():
	get_tree().paused = false
	visible = false


func _on_QuitButton_pressed():
	get_tree().change_scene("res://Menu/Title Screen.tscn")

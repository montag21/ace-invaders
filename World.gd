extends Node2D

func _ready():
	GameManager.init_world(self, $Background/Castle.position)
	
func _on_Restart_pressed():
	GameManager.reset()
	get_node("Fun/StacheGuyCounter").set_text("0")
	var dropships = get_tree().get_nodes_in_group("SHIPS")
	for n in dropships.size():
		dropships[n].queue_free()
	var stacheguys = get_tree().get_nodes_in_group("STACHE_GUYS")
	for n in stacheguys.size():
		stacheguys[n].queue_free()

func _on_Control_gui_input(_event):
	get_tree().set_input_as_handled()

func _on_ExitGame_pressed():
	get_tree().quit()

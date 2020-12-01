extends Control


func _ready():
	$"Menu/CenterRow/Buttons/Game Over".text = "BIG WIN!\nYOUR FINAL SCORE IS:\n%d" % ScoreManager.score

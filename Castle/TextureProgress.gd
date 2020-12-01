extends TextureProgress

func _ready():
	max_value = GameManager.CASTLE_MAX_HP * 5
	value = max_value
	GameManager.connect("castle_hp_changed", self, "_on_castle_hp_changed")

func _on_castle_hp_changed(castle_hp):
	$Tween.interpolate_property(self, "value", 0, castle_hp * 5, castle_hp/GameManager.CASTLE_MAX_HP, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()

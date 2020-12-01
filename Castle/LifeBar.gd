extends TextureProgress

func _on_Area2D_body_entered(body):
	if body.name == "Stacheling":
		print_debug(body.name + " entered!")
		$Tween.interpolate_property(self, "value", null, value - 1, 0.6, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()

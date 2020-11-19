extends AnimatedSprite

func trigger(_position, _scale = 1.0):
	position = _position
	scale = Vector2(_scale, _scale)
	play()
	yield(self, "animation_finished")
	queue_free()

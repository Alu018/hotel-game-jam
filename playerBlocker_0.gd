extends StaticBody2D

func _process(delta: float):
	if GameState.quest > 0:
		queue_free()

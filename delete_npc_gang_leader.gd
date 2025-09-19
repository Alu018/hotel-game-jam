extends Node2D

func _process(delta: float):
	if GameState.quest <= 1:
		get_parent().queue_free()

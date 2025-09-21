extends Node2D

func _process(delta: float):
	if GameState.quest >= 4 && GameState.get_flag("hasCalledAssociate") == true:
		get_parent().queue_free()

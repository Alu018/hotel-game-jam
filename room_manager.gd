extends Node

var spawnPointName: String = ""

func set_spawn(name: String):
	spawnPointName = name

func place_player(player: Node2D, sceneRoot: Node):
	if spawnPointName != "":
		var spawn = sceneRoot.get_node_or_null(spawnPointName)
		if not spawn:
			spawn = sceneRoot.find_child(spawnPointName, true, false) # recursive search
		if spawn:
			player.global_position = spawn.global_position

extends Node2D

func _ready():
	RoomManager.place_player(%Player, self)

func _process(delta: float):
	if GameState.quest >= 2:
		# If GangLeader exists in this scene, remove it
		var gang_leader = get_node_or_null("GangLeader")  # path to the node in the scene tree
		var cutscene_trigger = get_node_or_null("CutsceneTrigger")
		if gang_leader:
			gang_leader.queue_free()
			cutscene_trigger.queue_free()

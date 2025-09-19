extends Node2D

# If GangLeader exists in this scene, remove it
@onready var gang_leader = %GangLeader

func _ready():
	RoomManager.place_player(%Player, self)

func _process(delta):
	if GameState.quest <= 1:
		print("here")
		if gang_leader:
			print("gang leader here")
			gang_leader.queue_free()

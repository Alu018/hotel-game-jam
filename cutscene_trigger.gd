extends Area2D

@export var npc_node_path: NodePath  # drag the NPC node here
@onready var npc_node: Node
@onready var dialogueBox = %DialogueBox
@onready var player = %Player

var isTriggered: bool = false

func _ready():
	npc_node = get_node(npc_node_path)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if isTriggered:
		return  # prevent multiple triggers
	if body.name == "Player":
		isTriggered = true
		start_cutscene()

func start_cutscene():
	# Freeze player
	player.canMove = false

	# Start dialogue
	dialogueBox.currentLine = -1
	dialogueBox.start_dialogue(npc_node, dialogueBox.text_gangLeader_q1, player)

func _on_dialogue_box_dialogue_finished() -> void:
	print("dialogue ended from cutscene")
	
	# Trigger cutscene end - NPCs walk out of the room
	npc_node.walk_out()  # gang leader
	print(npc_node)
#
	#var gang1 = get_node("../GangMember1")
	#var gang2 = get_node("../GangMember2")
	#gang1.walk_out()
	#gang2.walk_out()

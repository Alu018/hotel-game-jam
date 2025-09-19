extends StaticBody2D

# passes in self as npc_node - so, root node of NPC
signal interact(npc_node)

@onready var player = %Player
@onready var interactIcon = $InteractionIndicator
@onready var interactText: Node = null
@onready var dialogueBox = %DialogueBox

var isPlayerNearby: bool = false
var npcName: String = "Concierge: "

func _ready():
	interactText = get_node_or_null("InteractText")
	
	interactIcon.visible = false
	if interactText: interactText.visible = false
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	dialogueBox.visible = false
	
func _on_body_entered(body):
	#print("body entered: ", body.name)
	if body.name == "Player":
		isPlayerNearby = true
		_update_indicator()

func _on_body_exited(body):
	#print("body exited: ", body.name)
	if body.name == "Player":
		isPlayerNearby = false
		_update_indicator()

func _update_indicator():
	# Only show indicator if player is nearby AND dialogue is not active
	#print("updating indicator: ", interactIcon.visible)
	interactIcon.visible = isPlayerNearby and (not dialogueBox.isActive)
	interactText.visible = isPlayerNearby and (not dialogueBox.isActive)
	# place interactIcon slightly above the player
	interactIcon.global_position = global_position - Vector2(-16, 26)
	interactText.global_position = global_position - Vector2(32, 32)


func _process(delta):
	if isPlayerNearby and Input.is_action_just_pressed("interact") and not dialogueBox.isActive && !GameState.isViewingInventory:
		print("emitting interact signal")
		emit_signal("interact", self)

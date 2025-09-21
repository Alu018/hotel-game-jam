extends Area2D

@onready var dialogueBox = %DialogueBox
@onready var sleepNode = %SleepNode
@onready var player = %Player

@onready var text_sleepTime = [
	{"text": "It's been a long day... time to go to sleep.", "choices": []}
]

func _ready():
	# Connect the area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" && GameState.quest == 8:
		dialogueBox.start_dialogue(sleepNode, text_sleepTime, player)

func _on_body_exited(body):
	pass

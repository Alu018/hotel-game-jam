extends Area2D

@onready var tutorial_panel = %Tutorial  # Access by unique name

func _ready():
	# Connect the area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Make sure tutorial starts hidden
	if tutorial_panel:
		tutorial_panel.visible = false

func _on_body_entered(body):
	if body.name == "Player" and tutorial_panel:
		tutorial_panel.visible = true

func _on_body_exited(body):
	if body.name == "Player" and tutorial_panel:
		tutorial_panel.visible = false

extends Area2D

@onready var darkness_overlay = $ColorRect  # Reference to the black ColorRect

func _ready():
	# Connect the area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Make sure the darkness starts visible
	darkness_overlay.visible = true

func _on_body_entered(body):
	if body.name == "Player":
		# Player entered - illuminate area (hide darkness)
		darkness_overlay.visible = false

func _on_body_exited(body):
	if body.name == "Player":
		# Player left - darken area (show darkness)
		darkness_overlay.visible = true

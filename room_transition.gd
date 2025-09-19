extends Area2D

@export_file("*.tscn") var targetScene # The path to the scene this portal leads to
@export var targetSpawn: String = ""  # (optional) name of spawn point in target scene
@export var roomName: String = "Room"  # The name to display in popup

# UI elements - add these to your door scene
@onready var room_popup = get_node_or_null("RoomPopup")  # Panel or Label
@onready var room_label = get_node_or_null("RoomPopup/RoomLabel") if room_popup else null  # Label to show room name
@onready var popup_area = $Area2D  # Change this to match your actual child Area2D name

func _ready():
	# Connect the parent Area2D (this one) for room transition
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Find and connect the child Area2D for popup (with error checking)
	popup_area = get_node_or_null("Area2D")  # Try common name first
	if not popup_area:
		popup_area = get_node_or_null("PopupArea2D")  # Try another name
	
	if popup_area:
		popup_area.connect("body_entered", Callable(self, "_on_popup_area_entered"))
		popup_area.connect("body_exited", Callable(self, "_on_popup_area_exited"))
	else:
		print("Warning: Child Area2D not found for popup trigger")
	
	# Hide popup initially (only if it exists)
	if room_popup:
		room_popup.visible = false
	else:
		print("Warning: RoomPopup UI node not found - you need to add it to the scene")

func _on_body_entered(body):
	# This handles entering the door (room transition)
	if body.name == "Player":
		# Disconnect all signals before changing scene to prevent errors
		if popup_area and popup_area.is_connected("body_entered", Callable(self, "_on_popup_area_entered")):
			popup_area.disconnect("body_entered", Callable(self, "_on_popup_area_entered"))
		if popup_area and popup_area.is_connected("body_exited", Callable(self, "_on_popup_area_exited")):
			popup_area.disconnect("body_exited", Callable(self, "_on_popup_area_exited"))
		
		# Hide popup before transitioning
		hide_room_popup()
		
		RoomManager.set_spawn(targetSpawn)
		get_tree().change_scene_to_file(targetScene)

func _on_popup_area_entered(body):
	# This handles showing the room name popup
	if body.name == "Player" and is_instance_valid(self):
		show_room_popup()

func _on_popup_area_exited(body):
	# This handles hiding the room name popup
	if body.name == "Player" and is_instance_valid(self):
		hide_room_popup()

func show_room_popup():
	if room_popup and room_label and is_instance_valid(room_popup):
		room_label.text = roomName
		room_popup.visible = true

func hide_room_popup():
	if room_popup and is_instance_valid(room_popup):
		room_popup.visible = false
	
	#extends Area2D
#@export_file("*.tscn") var targetScene # The path to the scene this portal leads to
#@export var targetSpawn: String = ""  # (optional) name of spawn point in target scene
#func _ready():
	#connect("body_entered", Callable(self, "_on_body_entered"))
#func onbody_entered(body):
	#if body.name == "Player":
		#RoomManager.set_spawn(targetSpawn)
		#get_tree().change_scene_to_file(targetScene)

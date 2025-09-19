extends Node2D

@onready var dialogueBox = %DialogueBox
@onready var blackScreen = %BlackScreen

func _ready():
	var usableRect = DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_size(usableRect.size)
	#DisplayServer.window_set_size(usableRect.size - Vector2i(512, 512))
	DisplayServer.window_set_position(usableRect.position)
	
	# Ensure window mode is reapplied when scene loads
	#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	RoomManager.place_player(%Player, self)
	
	if GameState.get_flag("hasSpokenMonologue") == true:
		print("spoken")
		if blackScreen: blackScreen.queue_free()
	
	if not MusicPlayerBG.playing:
		MusicPlayerBG.play()

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_dialogue_ended():
	print("Dialogue ended")


func _on_computer_table_broken_interact(npc_node: Variant) -> void:
	pass # Replace with function body.

extends "res://interact.gd"  # Replace with actual path

signal safe_opened(npc_node)

# Safe-specific variables
var isSafeOpen: bool = false
var safe_code = "5391"
var entered_code = ""
var entering_code = false

# UI elements - add these to your safe scene
@onready var safe_ui = $SafeUI  # Panel or Control node
@onready var instruction_label = $SafeUI/VBoxContainer/InstructionLabel
@onready var code_display = $SafeUI/VBoxContainer/CodeDisplay
@onready var close_button = $SafeUI/VBoxContainer/CloseButton

func _ready():
	super._ready()  # Call parent's _ready()
	visible = true
	
	# Override the NPC name for the safe
	npcName = "Safe: "
	
	# Setup safe UI
	safe_ui.visible = false
	instruction_label.text = "Enter safe code [with keyboard].\nPress ENTER to try code."
	code_display.text = "____"  # Show placeholder
	
	# Connect close button
	close_button.pressed.connect(_on_close_safe)
	
	# Connect to the interact signal
	interact.connect(_on_safe_interact)

func _on_safe_interact(npc_node):
	# Open the safe interface instead of dialogue
	if !isSafeOpen: open_safe_interface()

func open_safe_interface():
	player.canMove = false
	safe_ui.visible = true
	entered_code = ""
	entering_code = true
	update_code_display()
	
	# Pause the game or disable player movement if needed
	# get_tree().paused = true  # Uncomment if you want to pause

func _on_close_safe():
	player.canMove = true
	close_safe_interface()

func close_safe_interface():
	safe_ui.visible = false
	entering_code = false
	entered_code = ""
	
	# Unpause if you paused earlier
	# get_tree().paused = false

func update_code_display():
	# Show entered digits with underscores for remaining spots
	var display_text = ""
	for i in range(4):
		if i < entered_code.length():
			display_text += entered_code[i]
		else:
			display_text += "_"
	
	code_display.text = display_text

func _input(event):
	if not entering_code:
		return
		
	if event is InputEventKey and event.pressed:
		var key_pressed = event.keycode
		
		# Handle number input (0-9)
		if key_pressed >= KEY_0 and key_pressed <= KEY_9:
			if entered_code.length() < 4:
				var number = str(key_pressed - KEY_0)
				entered_code += number
				update_code_display()
		
		# Handle numpad numbers too
		elif key_pressed >= KEY_KP_0 and key_pressed <= KEY_KP_9:
			if entered_code.length() < 4:
				var number = str(key_pressed - KEY_KP_0)
				entered_code += number
				update_code_display()
		
		# Handle backspace
		elif key_pressed == KEY_BACKSPACE and entered_code.length() > 0:
			entered_code = entered_code.substr(0, entered_code.length() - 1)
			update_code_display()
		
		# Handle enter to submit code
		elif key_pressed == KEY_ENTER:
			if entered_code.length() == 4:
				check_safe_code()
		
		# Handle escape to close
		elif key_pressed == KEY_ESCAPE:
			close_safe_interface()

func check_safe_code():
	if entered_code == safe_code:
		print("Correct! Safe opened!")
		isSafeOpen = true
		emit_signal("safe_opened", self)
		close_safe_interface()
	else:
		print("Incorrect code!")
		entered_code = ""
		update_code_display()

# Override the update_indicator to work with safe UI
func _update_indicator():
	# Don't show indicator if safe UI is open
	interactIcon.visible = isPlayerNearby and (not dialogueBox.isActive) and (not entering_code)
	interactIcon.global_position = global_position - Vector2(0, 24)

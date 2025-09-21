extends CharacterBody2D

@export var SPEED = 85
@export var SPRINT_SPEED = 85
var canMove = true
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# NEW SPRINT SYSTEM VARIABLES
var max_stamina = 10.0  # 1 second of sprint
var current_stamina = 1.0
var stamina_drain_rate = 1.0  # Drains 1.0 per second when sprinting
var stamina_regen_rate = 0.5  # Regens 0.5 per second when not sprinting
var can_sprint = true
var is_sprinting = false

# SPRINT BAR UI - Add these nodes to your player scene
@onready var sprint_bar_container = $SprintBarContainer  # Control node
@onready var sprint_bar_background = $SprintBarContainer/SprintBarBackground  # ColorRect (gray)
@onready var sprint_bar_fill = $SprintBarContainer/SprintBarBackground/SprintBarFill  # ColorRect (green/yellow/red)

func _ready():
	# Position sprint bar above player (adjust as needed)
	sprint_bar_container.position = Vector2(-6, -12)  # 50px wide bar, 40px above player
	current_stamina = max_stamina
	#update_sprint_bar()
	sprint_bar_container.visible = false

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Check if trying to sprint and can sprint
	#var trying_to_sprint = Input.is_action_pressed("speed_up")
	var trying_to_sprint = false
	
	# FIXED: Check both current_stamina AND can_sprint
	if trying_to_sprint and current_stamina > 0 and can_sprint and input_direction != Vector2.ZERO:
		is_sprinting = true
		velocity = input_direction * SPRINT_SPEED
	else:
		is_sprinting = false
		velocity = input_direction * SPEED

func _input(event):
	# Remove the old sprint logic since we handle it in get_input() now
	pass

var footstepCooldown = 0.5 # seconds
var footstepTimer = 0.0

func _physics_process(delta):
	# if you can't move, just return
	if !canMove:
		return
		
	# Handle stamina system
	#handle_stamina(delta)
	
	get_input()
	move_and_slide()
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	# Decide animation
	if input_vector == Vector2.ZERO:
		# IDLE animations
		if anim.animation.begins_with("walk"): # keep last direction
			anim.animation = anim.animation.replace("walk", "idle")
	else:
		# WALK animations
		if abs(input_vector.x) > abs(input_vector.y):
			anim.animation = "walk_side"
			anim.flip_h = input_vector.x < 0
		elif input_vector.y < 0:
			anim.animation = "walk_up"
		else:
			anim.animation = "walk_down"
			
		footstepTimer -= delta
		if footstepTimer <= 0.0:
			SfxFootstep.play_random()
			footstepTimer = footstepCooldown
	anim.play()

# Handle stamina drain and regeneration
func handle_stamina(delta):
	if is_sprinting:
		# Drain stamina
		current_stamina -= stamina_drain_rate * delta
		current_stamina = max(0, current_stamina)
		
		# Stop sprinting if out of stamina
		if current_stamina <= 0:
			can_sprint = false
			is_sprinting = false
	else:
		# Regenerate stamina
		current_stamina += stamina_regen_rate * delta
		current_stamina = min(max_stamina, current_stamina)
		
		# Can sprint again once stamina is above 0.1 (small buffer)
		if current_stamina >= 0.9:
			can_sprint = true
	
	update_sprint_bar()

# NEW FUNCTION - Update the visual sprint bar
func update_sprint_bar():
	if not sprint_bar_fill:
		return
		
	# Show/hide bar based on whether player is trying to sprint or stamina isn't full
	var should_show_bar = Input.is_action_pressed("speed_up") or current_stamina < max_stamina
	sprint_bar_container.visible = should_show_bar
	
	# Update bar fill percentage
	var stamina_percent = current_stamina / max_stamina
	sprint_bar_fill.size.x = sprint_bar_background.size.x * stamina_percent
	
	# Change color based on stamina level
	if stamina_percent > 0.6:
		sprint_bar_fill.color = Color.GREEN
	elif stamina_percent > 0.3:
		sprint_bar_fill.color = Color.YELLOW
	else:
		sprint_bar_fill.color = Color.RED

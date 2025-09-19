extends CharacterBody2D

@export var SPEED = 85
var canMove = true
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * SPEED

func _input(event):
	if event.is_action_pressed("speed_up"):
		SPEED = 300
	if event.is_action_released("speed_up"):
		SPEED = 80

var footstepCooldown = 0.5 # seconds
var footstepTimer = 0.0

func _physics_process(delta):
	# if you can't move, just return
	if !canMove:
		return
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

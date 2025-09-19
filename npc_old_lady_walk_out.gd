extends Node2D

signal oldLadyDoneWalking

@onready var old_lady_parent = get_parent()  # Reference to OldLady (StaticBody2D)
@onready var visual = old_lady_parent.get_node("Visual")  # Node2D that holds the sprite
@onready var sprite = visual.get_node("AnimatedSprite2D")
@onready var player = %Player  # Reference to player

var path = []
var facing = []
var flip_h = []
var current_index = 0
var current_target: Vector2
var speed = 60.0  # Slower speed for elderly character
var walking = false

func walk_out():
	print("walking out")
	#if player: 
		#print("player move false")
		#player.canMove = false
	
	# Old lady's path: right 35px, up 40px, right 250px
	path = [
		Vector2(35, 0),    # walk right 35px
		Vector2(0, -40),   # walk up 40px  
		Vector2(250, 0)    # walk right 250px
	]
	
	facing = [
		"side",  # right
		"up",    # up
		"side"   # right
	]
	
	flip_h = [
		false,   # right (don't flip)
		false,   # up (ignore flip)
		false    # right (don't flip)
	]
	
	current_index = 0
	current_target = old_lady_parent.position + path[current_index]
	set_animation()
	walking = true

func _physics_process(delta):
	if not walking:
		return
	else:
		if player:
			print("setting player canmove to false")
			player.canMove = false
	
	if current_index >= path.size():
		# Finished path - trigger cutscene
		sprite.play("idle_down")
		walking = false
		if player:
			player.canMove = true
		return
	
	var dir = (current_target - old_lady_parent.position).normalized()
	old_lady_parent.position += dir * speed * delta
	
	if old_lady_parent.position.distance_to(current_target) < 1.0:
		old_lady_parent.position = current_target
		current_index += 1
		
		if current_index < path.size():
			current_target = old_lady_parent.position + path[current_index]
			set_animation()
		else:
			# Path completed
			sprite.play("idle_down")
			walking = false
			get_parent().queue_free()
			print("path done")
			oldLadyDoneWalking.emit()
			#if player:
				#print("path done - player moves now")
				#player.canMove = true

func set_animation():
	sprite.play("walk_%s" % facing[current_index])
	sprite.flip_h = flip_h[current_index]

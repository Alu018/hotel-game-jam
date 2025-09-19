extends "res://interact.gd"

@onready var visual = $Visual        # Node2D that holds the sprite
@onready var sprite = visual.get_node("AnimatedSprite2D")

var path = []
var facing = []
var flip_h = []
var current_index = 0
var current_target: Vector2
var speed = 50.0
var walking = false

func walk_out():
	# Path in straight lines only
	path = [
		Vector2(0, 30),    # walk straight down
		Vector2(-20, 0),   # walk left
		Vector2(0, 30),    # walk straight down
		Vector2(20, 0),    # walk right
		Vector2(0, 45)     # final straight down to exit
	]
	
	facing = [
		"down",  # down
		"side",  # left
		"down",  # down
		"side",  # right
		"down"   # down
	]
	
	flip_h = [
		false,   # down (ignore)
		true,    # left
		false,   # down
		false,   # right
		false    # down
	]

	current_index = 0
	current_target = visual.position + path[current_index]
	_set_animation()
	walking = true


func _physics_process(delta):
	if not walking:
		return
	else:
		player.canMove = false
	
	if current_index >= path.size():
		# Finished path
		sprite.play("idle_down")
		hide()
		walking = false
		player.canMove = true
		return

	var dir = (current_target - visual.position).normalized()
	visual.position += dir * speed * delta

	if visual.position.distance_to(current_target) < 1.0:
		visual.position = current_target
		current_index += 1
		if current_index < path.size():
			current_target = visual.position + path[current_index]
			_set_animation()
		else:
			sprite.play("idle_down")
			hide()
			walking = false
			player.canMove = true
#			go to quest 2
			GameState.advance_quest()
			print(GameState.quest)


func _set_animation():
	sprite.play("walk_%s" % facing[current_index])
	sprite.flip_h = flip_h[current_index]

extends CanvasLayer

@onready var quest_label = $QuestLabel
@onready var game_state = get_node("/root/GameState")

func _process(delta):
	# Increment quest
	if Input.is_action_just_pressed("inc_quest"):
		game_state.advance_quest()

	# Decrement quest
	if Input.is_action_just_pressed("dec_quest"):
		game_state.quest = max(0, game_state.quest - 1)

	# Update label
	quest_label.text = "Quest: %d" % game_state.quest

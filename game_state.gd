extends Node

# Current main quest stage
var quest: int = 0
var isViewingInventory: bool = false

# dictionary for misc flags (branching quests)
var flags := {
	"hasSpokenMonologue": false,
	"hasTriedPhone": 0,
	"hasAskedConciergePhone": 0,
	"hasCalledAssociate": 0,
	"hasMetAssociate": 0,
	"hasPrintedLabel": 0,
	"GaveGlasses": 0,
	"GotPaperClue1": 0,
	"GotPaperClue2": 0
}

# Example: advance the quest
func advance_quest():
	quest += 1

func set_flag(name: String, value):
	flags[name] = value

func get_flag(name: String) -> bool:
	return flags.has(name) and flags[name]

func _process(delta: float):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		quest = 0


# quests
# 0: talk to concierge
# 1: go to hotel room, talk to gang leader
# 2: sign -> talk to concierge abt wine cellar
# 3: go to room + open suitcase to get items

extends AudioStreamPlayer

var footstepSounds = [
	preload("res://sfx/Concrete1.wav"),
	preload("res://sfx/Concrete2.wav")
]

func play_random():
	stream = footstepSounds.pick_random()
	play()

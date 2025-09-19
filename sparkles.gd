extends AnimatedSprite2D

func _ready():
	var anim_names = sprite_frames.get_animation_names()
	for anim_name in anim_names:
		var random_fps = randf_range(4.0, 6.0)
		#sprite_frames.set_animation_speed(anim_name, random_fps)

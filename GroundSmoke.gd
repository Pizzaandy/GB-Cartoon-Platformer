extends AnimatedSprite


export var randomize_angle = true


func _ready():
	frame = 0
	flip_h = choose_randomly([true, false])
	if randomize_angle:
		rotation_degrees = rand_range(0, 360)


func choose_randomly(list_of_entries):
	return list_of_entries[randi() % list_of_entries.size()]


func _on_SmokeSprite_animation_finished():
	queue_free()

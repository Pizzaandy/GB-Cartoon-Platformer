extends AnimatedSprite


# Declare member variables here. Examples:
var activation_t = -1
var eat_t = 0
var timer_running = false
var activated = false

export var target_scene = "res://Soccer.tscn"

signal do_camera_wipe

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	var overlapping = $Area2D.get_overlapping_bodies()
	
	activation_t = max(activation_t - 1, -1)
	if activated:
		eat_t += 1
		if eat_t == 33:
			animation = "Close"
		if eat_t == 45:
			for player in overlapping:
				player.visible = false
		if eat_t == 70:
			animation = "Disappear"
		if eat_t == 100:
			animation = "Idle"
		if eat_t == 110:
			emit_signal("do_camera_wipe")
		if eat_t == 210:
			get_tree().change_scene(target_scene)
	
	if activation_t == 0:
		activate()
		for player in overlapping:
			player.frozen = true
	if (overlapping.size() >= 1):
		modulate = Color(1, 1, 1, 1)
		if timer_running == false:
			timer_running = true
			activation_t = 180
	else:
		timer_running = false
		activation_t = -1
		modulate = Color(1, 1, 1, 0.5)
		

func activate():
	activated = true
	animation = "Open"
	z_index = 1000

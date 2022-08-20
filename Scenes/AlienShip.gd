extends KinematicBody2D


var intro_state_idx = 0
var timer = 0
var target_anim = "Idle"
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "Idle"


func _physics_process(delta):
	timer = max(timer-1, 0)
	if intro_state_idx == 0:
		var _collision = move_and_collide(Vector2(0, delta * 200))
		if is_instance_valid(_collision):
			intro_state_idx += 1
			timer = 120
	elif intro_state_idx == 1:
		target_anim = "Land"
		if timer == 0:
			intro_state_idx += 1
	elif intro_state_idx == 2:
		target_anim = "AlienIntro"
	elif intro_state_idx == 3:
		target_anim = "AlienIdle"
		

func _on_AnimatedSprite_frame_changed():
	var current_anim = $AnimatedSprite.animation
	var frame = $AnimatedSprite.frame
	
	if target_anim == "Land":
		if frame == 0:
			current_anim = "Land"
	elif target_anim == "AlienIntro":
		current_anim = target_anim
		if frame == 45:
			intro_state_idx += 1
	else:
		current_anim = target_anim
	
	$AnimatedSprite.animation = current_anim

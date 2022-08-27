extends KinematicBody2D


var intro_state_idx = 0
var timer = 0
var target_anim = "Idle"
var fade_in_shadow = false
var shadow_alpha = 0

var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "Idle"
	$ShadowSprite.modulate = Color(1, 1, 1, shadow_alpha)
	$AnimationPlayer.play("Start")

func damage(amnt):
	# play some anim here mayve
	$HitEffect.play("Hit")
	health -= amnt
	if health <= 0:
		die()

func die():
	#play die anim or smth
	# TEMP TMEP TEMP MTPE TEMP TEMP
	$AnimationPlayer.play_backwards("Start")
	# TEMP TME TEMP TEMP TEMP
	get_parent().boss_killed()

func _physics_process(delta):
	pass
#	timer = max(timer-1, 0)
#	if intro_state_idx == 0:
#		var _collision = move_and_collide(Vector2(0, delta * 200))
#		if is_instance_valid(_collision):
#			intro_state_idx += 1
#			timer = 80
#	elif intro_state_idx == 1:
#		target_anim = "Land"
#		fade_in_shadow = true
#		if timer == 0:
#			intro_state_idx += 1
#			timer = 30
#	elif intro_state_idx == 2:
#		target_anim = "AlienIntroKick"
#		if timer == 0:
#			intro_state_idx += 1
#	elif intro_state_idx == 3:
#		target_anim = "AlienIntro"
#	elif intro_state_idx == 4:
#		target_anim = "AlienIdle"
		
#
func _on_AnimatedSprite_frame_changed():
	pass
#	var current_anim = $AnimatedSprite.animation
#	var frame = $AnimatedSprite.frame
#
#	if fade_in_shadow:
#		shadow_alpha = min(shadow_alpha + 0.05, 0.6)
#	$ShadowSprite.modulate = Color(1, 1, 1, shadow_alpha)
#
#	if target_anim == "Land":
#		if frame == 0:
#			current_anim = "Land"
#	elif target_anim == "AlienIntro":
#		current_anim = target_anim
#		if frame == 41:
#			intro_state_idx += 1
#	else:
#		current_anim = target_anim
#
#	$AnimatedSprite.animation = current_anim

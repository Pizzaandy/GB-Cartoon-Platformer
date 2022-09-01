extends KinematicBody2D

var target_frame = -1
var intro_state_idx = 0
var attack_state_idx = -2
var timer = 0
var target_anim = "Idle"
var fade_in_shadow = false
var shadow_alpha = 0

var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "Idle"
	#$ShadowSprite.modulate = Color(1, 1, 1, shadow_alpha)
	#$AnimationPlayer.play("Start")


func damage(amnt):
	# play some anim here mayve
	$HitEffect.play("Hit")
	health -= amnt
	if health <= 0:
		die()


func die():
	#play die anim or smth
	# TEMP TMEP TEMP MTPE TEMP TEMP
	#$AnimationPlayer.play_backwards("Start")
	# TEMP TME TEMP TEMP TEMP
	get_parent().boss_killed()


func _physics_process(delta):	
	timer = max(timer-1, 0)
	if intro_state_idx == 0:
		var _collision = move_and_collide(Vector2(0, delta * 320))
		if is_instance_valid(_collision):
			intro_state_idx += 1
			timer = 80
	elif intro_state_idx == 1:
		target_anim = "Land"
		fade_in_shadow = true
		if timer == 0:
			intro_state_idx += 1
			timer = 30
	elif intro_state_idx == 2:
		target_anim = "AlienIntroKick"
		if timer == 0:
			intro_state_idx += 1
	elif intro_state_idx == 3:
		target_anim = "AlienIntro"
	elif intro_state_idx == 4:
		target_anim = "AlienIdle"
		$AttackTimer.start()
		intro_state_idx = -1
	
	if attack_state_idx == -1:
		target_anim = "AlienIdle"
	elif attack_state_idx == 0:
		target_anim = "AlienChargeUp"
	elif attack_state_idx == 1:
		target_anim = "AlienChargeUpBoil"
		if timer == 0:
			attack_state_idx += 1
			timer = 30
	elif attack_state_idx == 2:
		target_anim = "AlienFire"
		if timer == 0:
			attack_state_idx += 1
	elif attack_state_idx == 3:
		target_anim = "AlienFireReturn"


func _on_AnimatedSprite_frame_changed():
	
	$ShadowSprite.modulate = Color(1, 1, 1, shadow_alpha)
	
	if target_frame != -1:
		$AnimatedSprite.frame = target_frame
		target_frame = -1
	
	var current_anim = $AnimatedSprite.animation
	var frame = $AnimatedSprite.frame

	if fade_in_shadow:
		shadow_alpha = min(shadow_alpha + 0.05, 0.6)
	$ShadowSprite.modulate = Color(1, 1, 1, shadow_alpha)

	if target_anim == "Land":
		if frame == 0:
			current_anim = "Land"
	elif target_anim == "AlienIntro":
		current_anim = target_anim
		if frame == 41:
			intro_state_idx += 1
	elif intro_state_idx != -1:
		current_anim = target_anim
		
	if target_anim == "AlienChargeUp":
		if current_anim == "AlienIdle":
			if frame == 14:
				print("alien charging!")
				current_anim = target_anim
		elif current_anim == "AlienChargeUp" and frame == 7:
			attack_state_idx += 1
			timer = 80
	elif target_anim == "AlienFireReturn":
		if current_anim == "AlienFireReturn":
			if frame == 15:
				attack_state_idx = -1
				target_anim = "AlienIdle"
				target_frame = 10
		current_anim = target_anim
	else:
		current_anim = target_anim

	$AnimatedSprite.animation = current_anim



func _on_AttackTimer_timeout():
	attack_state_idx = 0

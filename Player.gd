extends KinematicBody2D

enum State {GROUND, AIR}
var state = State.GROUND
var target_anim_state = "Idle"
var anim_finished = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ground_smoke_scene = preload("res://Scenes/GroundSmoke.tscn")
var land_poof_scene = preload("res://Scenes/LandPoof.tscn")

# walk properties

export var gravity = 6000
export var jump_speed = 1900

export var walk_speed = 1000
export var ground_deceleration = 9500
export var ground_acceleration = 7000
export var ground_friction = 6000
export var air_deceleration = 7000
export var air_acceleration = 6000
export var air_friction = 2000
export var min_cancelable_jump_scalar = 0.1

const JUMP_BUFFER_FRAMES = 5
const VELOCITY_EPSILON = 0.1

var jump_buffer_count = 0
var kicked = false
var KICKING_FRAMES = 20
var kick_frame_count = 0
var kick_ended = false

var frozen = false

var velocity = Vector2(0, 0)
var jump_pressed = false
var jump_ended = false
var move_direction = 0
var x_stretch = 1
var y_stretch = 1
var sprite_height = 540
var frame_updated = false
var shadow_scale = 1

# gun
var gun_enabled = true
export (PackedScene) var projectile
var shooting = false
var shoot_delay_done = true

var max_health = 3
var health = max_health

func damage(amnt):
	health -= amnt
	if health <= 0:
		pass
		#TODO PLAYER DEATH

func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("jump"):
		jump_buffer_count = JUMP_BUFFER_FRAMES
	if event.is_action_pressed("shoot") && gun_enabled:
		shooting = true
	elif event.is_action_released("shoot") || !gun_enabled:
		shooting = false


func state_ground(dt):
	jump_ended = true
	kick_ended = false
	kicked = false
	if not is_on_floor():
		state = State.AIR
		target_anim_state = "Fall"
		#print("falling")
		return
	elif jump_buffer_count > 0:
		if not frozen:
			velocity = player_jump(velocity)
		state = State.AIR
		return
	
	if Input.is_action_just_pressed("kick"):
		var _collision = move_and_collide(Vector2(0, -20))
		if not frozen:
			kick()
		state = State.AIR
		return
	
	x_stretch = lerp(x_stretch, 1, 0.12)
	y_stretch = lerp(y_stretch, 1, 0.12)
	
	if move_direction != 0:
		target_anim_state = "Run"
	else:
		target_anim_state = "Idle"
	
	velocity = horizontal_move(
		velocity, 
		move_direction, 
		ground_acceleration, 
		ground_deceleration, 
		ground_friction,
		dt
	)


func horizontal_move(
		current_velocity, 
		direction, 
		acceleration, 
		braking_deceleration,
		friction_deceleration,
		dt
	):
	if frozen:
		return Vector2(0, current_velocity.y)
	if ( # if moving in opposite direction of velocity...
		direction == -sign(current_velocity.x) and 
		abs(current_velocity.x) > VELOCITY_EPSILON
	):
		# apply braking
		current_velocity.x += direction * braking_deceleration * dt
	elif direction != 0: # if moving...
		# apply speed-up acceleration
		current_velocity.x += direction * acceleration * dt
		current_velocity.x = clamp(current_velocity.x, -walk_speed, walk_speed)
	else:
		# apply friction
		current_velocity.x = move_toward(
			current_velocity.x, 0, friction_deceleration * dt
		)
	return current_velocity


func state_air(dt):
	if is_on_floor():
		state = State.GROUND
		on_land()
		velocity.y = 0
		return
		
	if Input.is_action_pressed("kick"):
		kick()
			
	# euler integration (good enough :sunglasses:)
	velocity.y += gravity * dt
	x_stretch = lerp(x_stretch, 1, 0.1)
	y_stretch = lerp(y_stretch, 1, 0.1)
	
	if velocity.y > 10 and target_anim_state != "Kick":
		target_anim_state = "Fall"
	
	if (
		jump_ended == false
		and not Input.is_action_pressed("jump")
		and velocity.y < jump_speed * min_cancelable_jump_scalar
	):
		jump_ended = true
		# TODO: change how this works. interpolation or curve?
		velocity.y = velocity.y * 0.35
		#print("jump cancelled!")

	var previous_x_velocity = velocity.x
	velocity = horizontal_move(
		velocity, 
		move_direction, 
		air_acceleration, 
		air_deceleration, 
		air_friction,
		dt
	)
	if kick_frame_count > 0:
		velocity.y = 0
		velocity.x = previous_x_velocity * 0.88
		target_anim_state = "Kick"
	else:
		if kicked and not kick_ended:
			kick_ended = true
			target_anim_state = "KickEnd"


func player_jump(current_velocity):
	jump_buffer_count = 0
	jump_ended = false
	#print("jumped")
	#x_stretch = 0.7
	#y_stretch = 1.3
	$SoundJump.pitch_scale = rand_range(0.9, 1.1)
	$SoundJump.play()
	target_anim_state = "Jump"
	return Vector2(current_velocity.x, -jump_speed)


func on_land():
	$SoundLand.pitch_scale = rand_range(0.9, 1.1)
	$SoundLand.play()
	#if abs(velocity.y) > 0.01:
		#instance_create(land_poof_scene, position)
	if jump_buffer_count > 0:
		pass
	if move_direction != 0:
		target_anim_state = "LandRun"
	else:
		target_anim_state = "Land"
		
		
func kick():
	if not kicked:
		kicked = true
		kick_frame_count = KICKING_FRAMES
		target_anim_state = "Kick"
		$SoundKick.pitch_scale = rand_range(0.9, 1.1)
		$SoundKick.play()
		if $AnimatedSprite.flip_h:
			velocity.x = -clamp(2.5*abs(velocity.x), 1200, 5000)
		else:
			velocity.x = clamp(2.5*abs(velocity.x), 1200, 5000)


func _physics_process(delta):
	var left_input = Input.is_action_pressed("walk_left")
	var right_input = Input.is_action_pressed("walk_right")
	move_direction = int(right_input) - int(left_input)
	
	if move_direction != 0:
		$ShootCenter.scale.x = move_direction
	if shooting:
		var up_input = Input.is_action_pressed("up")
		var down_input = Input.is_action_pressed("down")
		var hand_rotation_deg = 0
		if move_direction != 0:
			if up_input:
				hand_rotation_deg -= 45 * move_direction
			if down_input:
				hand_rotation_deg += 45 * move_direction
		else:
			if up_input:
				hand_rotation_deg -= 90 * -sign(float($AnimatedSprite.flip_h) - 0.5)
			if down_input:
				hand_rotation_deg += 90 * -sign(float($AnimatedSprite.flip_h) - 0.5)
		$ShootCenter.rotation_degrees = hand_rotation_deg
		$ShootCenter.visible = true
		if shoot_delay_done:
			var bullet = projectile.instance()
			get_parent().add_child(bullet)
			bullet.global_transform = $ShootCenter/BulletSpawnPosition.global_transform
			bullet.launch($ShootCenter/BulletSpawnPosition.global_position - $ShootCenter.global_position, 2000)
			shoot_delay_done = false
			$ShootTimer.start()
		# just in case
		elif $ShootTimer.time_left == 0:
			$ShootTimer.start()
	else:
		$ShootCenter.visible = false
	
	if state == State.GROUND:
		state_ground(delta)
		#velocity = move_and_slide_with_snap(velocity, Vector2(0, 5), Vector2.UP)
	elif state == State.AIR:
		state_air(delta)
		#velocity = move_and_slide(velocity, Vector2.UP, true)
	velocity = move_and_slide_with_snap(velocity, Vector2(0, 5), Vector2.UP)
	
	var current_anim = get_node("AnimatedSprite").animation
	var target_frame = -1
	#if get_node("AnimatedSprite").frame == get_node("AnimatedSprite").frames.get_frame_count(current_anim)-1:
		#anim_finished = true
		
	if target_anim_state == "Idle":
		if current_anim == "Run":
			current_anim = "RunStop"
			target_frame = int(5 - (5 * (abs(velocity.x)-20)/walk_speed))
			target_frame = clamp(target_frame-1, 0, 1)
		elif (
			current_anim == "RunStop" 
			or current_anim == "Land"
			or current_anim == "LandRun"
		):
			if anim_finished:
				current_anim = "Idle"
		else:
			current_anim = target_anim_state
	elif target_anim_state == "Run":
		if current_anim == "LandRun":
			if anim_finished:
				current_anim = "Run"
				target_frame = 8
		elif current_anim == "Idle":
			if frame_updated:
				target_frame = 4
			current_anim = target_anim_state
		else:
			current_anim = target_anim_state
	elif target_anim_state == "Fall":
		if current_anim == "KickEnd":
			if anim_finished:
				current_anim = "Fall"
				target_frame = 6
		else:
			current_anim = "Fall"
	else:
		current_anim = target_anim_state
	
	anim_finished = false
	frame_updated = false
	
	if $GroundCast.is_colliding():
		var ground_pos = $GroundCast.get_collision_point()
		var height_diff = ground_pos.y - position.y
		$ShadowSprite.position = Vector2(0, 2*height_diff)
		shadow_scale = (700 - abs(height_diff)) / 700
	else:
		shadow_scale = 0
		$ShadowSprite.scale = Vector2(0, 0)
	
	if frozen:
		current_anim = "Idle"
	
	get_node("AnimatedSprite").animation = current_anim
	#get_node("AnimatedSprite").offset = Vector2(0, -0.25*sprite_height*y_stretch + 0.5*sprite_height)
	
	if frozen:
		pass
	elif current_anim == "Run":
		var speed_scalar = clamp((abs(velocity.x)+20)/walk_speed, 0.5, 1)
		$AnimatedSprite.speed_scale = speed_scalar
		$SoundRun.pitch_scale = 0.955 * speed_scalar
		if not $SoundRun.playing:
			$SoundRun.play()
	else:
		$AnimatedSprite.speed_scale = 1
		$SoundRun.stop()
	
	#var current_facing = get_node("AnimatedSprite").flip_h	
	if current_anim != "Kick" and current_anim != "KickEnd" and not frozen:
		if move_direction == 1:
			$AnimatedSprite.flip_h = false
		if move_direction == -1:
			$AnimatedSprite.flip_h = true
		
	if target_frame != -1:
		$AnimatedSprite.frame = target_frame
		
	
	jump_buffer_count = max(jump_buffer_count - 1, 0)
	kick_frame_count = max(kick_frame_count - 1, 0)


func _on_AnimatedSprite_animation_finished():
	anim_finished = true


func _on_AnimatedSprite_frame_changed():
	#get_node("AnimatedSprite").scale = Vector2(x_stretch, y_stretch)
	frame_updated = true
	if $AnimatedSprite.animation == "Run" and abs(velocity.x) > 0.9*walk_speed:
		print(velocity.x)
		if $AnimatedSprite.frame == 3 or $AnimatedSprite.frame == 9:
			instance_create(ground_smoke_scene, position)
			
	$ShadowSprite.scale = Vector2(shadow_scale, 1.7*shadow_scale)
			

func instance_create(scene, pos):
	var new_scene = scene.instance()
	new_scene.position = pos
	get_parent().add_child(new_scene)

func _on_ShootTimer_timeout():
	shoot_delay_done = true

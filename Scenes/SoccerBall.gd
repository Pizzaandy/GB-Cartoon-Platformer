extends RigidBody2D

var max_speed = 1700
var push_out_speed = 800
var player_overlap_frames = 0

var ignored_bodies = []
var skip_unstuck = false

var shadow_scale = 1
var anim_angle = 0
var sprite_path = ""
var shadow_path = ""


func _ready():
	var new_sprite = $AnimatedSprite.duplicate()
	$AnimatedSprite.queue_free()
	get_parent().add_child(new_sprite)
	sprite_path = new_sprite.get_path()
	
	var new_shadow = $ShadowSprite.duplicate()
	$ShadowSprite.queue_free()
	get_parent().add_child(new_shadow)
	shadow_path = new_shadow.get_path()


func _process(delta):
	if position.y >= 405.900055:
		position.y = 405.900055
	get_node(sprite_path).position = position
	get_node(shadow_path).position = Vector2(position.x, 475)
	shadow_scale = (1500 - abs(position.y - 475)) / 1500


func _physics_process(delta):
	linear_velocity.x = clamp(linear_velocity.x, -max_speed, max_speed)
	linear_velocity.y = clamp(linear_velocity.y, -max_speed, max_speed)
	var colliding = get_colliding_bodies()
	if colliding.size() >= 2:
		if colliding.size() == 2:
			for collider in colliding:
				if collider.is_in_group("floor"):
					skip_unstuck = true
					print("skip unstuck")
		if not skip_unstuck:
			for collider in colliding:
				if collider.is_in_group("player"):
					collider.ball_overlap_frames = 30
					if not collider in ignored_bodies:
						add_collision_exception_with(collider)
						ignored_bodies.append(collider)
						linear_velocity.y = -1200
						#print("exception added")
		skip_unstuck = false
	if colliding.size() >= 1:
		for collider in colliding:
			if collider.is_in_group("player"):
				if (
					collider.position.y - position.y < 10
					and collider.velocity.y >= 0
				):
					collider.jump_ended = true
					linear_velocity.y = 0.35*max_speed
					collider.move_and_collide(Vector2(0,-30))
					collider.kick_frame_count = 0
					collider.state = collider.State.AIR
					collider.velocity.y = -0.77*collider.jump_speed
					collider.instance_create(collider.bounce_poof_scene, collider.position)
					if collider.name == "PlayerBody":
						linear_velocity.x = 600
					else:
						linear_velocity.x = -600
				else:
					linear_velocity.x = (
						sign(linear_velocity.x) * clamp(abs(linear_velocity.x), 200, 1000)
					)
					linear_velocity.y = clamp(linear_velocity.y, -1700, -900)
	if colliding.size() <= 1:
		for body in ignored_bodies:
			if body.ball_overlap_frames <= 1:
				remove_collision_exception_with(body)
				#print("exception removed")
				ignored_bodies.erase(body)
				


func _on_AnimatedSprite_frame_changed():
	get_node(sprite_path).scale = Vector2(rand_range(0.265,0.275), rand_range(0.265,0.275))
	anim_angle = transform.get_rotation()
	get_node(sprite_path).rotation = anim_angle
	get_node(shadow_path).scale = Vector2(0.54, 0.84) * shadow_scale

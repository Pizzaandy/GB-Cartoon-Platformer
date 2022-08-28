extends RigidBody2D

var max_speed = 1700
var push_out_speed = 800
var player_overlap_frames = 0

var ignored_bodies = []

var shadow_scale = 1


func _physics_process(delta):
	linear_velocity.x = clamp(linear_velocity.x, -max_speed, max_speed)
	linear_velocity.y = clamp(linear_velocity.y, -max_speed, max_speed)
	var colliding = get_colliding_bodies()
	if colliding.size() >= 2:
		for collider in colliding:
			if collider.is_in_group("player"):
				collider.ball_overlap_frames = 30
				if not collider in ignored_bodies:
					add_collision_exception_with(collider)
					ignored_bodies.append(collider)
					linear_velocity.y = -1200
					#print("exception added")
	if colliding.size() >= 1:
		for collider in colliding:
			if collider.is_in_group("player"):
				if collider.position.y - position.y < -25:
					collider.velocity.y = -0.77*collider.jump_speed
					collider.jump_ended = true
					linear_velocity.y = 0.35*max_speed
					if collider.name == "PlayerBody":
						linear_velocity.x = 600
					else:
						linear_velocity.x = -600
				else:
					linear_velocity.x = (
						sign(linear_velocity.x) * max(abs(linear_velocity.x), 300)
					)
					linear_velocity.y = min(linear_velocity.y, -800)
	if colliding.size() <= 1:
		for body in ignored_bodies:
			if body.ball_overlap_frames <= 1:
				remove_collision_exception_with(body)
				#print("exception removed")
				ignored_bodies.erase(body)
				
	if $GroundCast.is_colliding():
		var ground_pos = $GroundCast.get_collision_point()
		var height_diff = ground_pos.y - position.y
		$ShadowSprite.position = Vector2(0, 2*height_diff)
		shadow_scale = (800 - abs(height_diff)) / 800
	else:
		shadow_scale = 0
		$ShadowSprite.scale = Vector2(0, 0)

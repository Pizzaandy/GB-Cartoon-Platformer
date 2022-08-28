extends RigidBody2D

var max_speed = 1700
var push_out_speed = 800
var player_overlap_frames = 0

var ignored_bodies = []
var skip_unstuck = false

var shadow_scale = 1


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
					and collider.velocity.y > 0
				):
					collider.velocity.y = -0.77*collider.jump_speed
					collider.jump_ended = true
					linear_velocity.y = 0.35*max_speed
					collider.move_and_collide(Vector2(0,-30))
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
	if position.y >= 405.900055:
		position.y = 405.900055
				

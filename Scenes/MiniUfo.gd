extends StaticBody2D

export (PackedScene) var Bomb

var left_target = null
var right_target = null
var move_right = true

var health = 8

func damage(amnt):
	health -= amnt
	if health <= 0:
		die()
	else:
		$Hit.play("hit")

func die():
	$Position2D.visible = false
	$Die.visible = true
	$Die.play("default")
	
	owner.ufo_count -= 1

func _ready():
	set_physics_process(true)
	$BombTimer.start()

func _physics_process(delta):
	# bad code
	var left_dist = global_position.distance_to(left_target)
	var right_dist = global_position.distance_to(right_target)
	if move_right && right_dist <= 100.0:
		move_right = false
	elif !move_right && left_dist <= 100.0:
		move_right = true
	if move_right:
		global_position = lerp(global_position, right_target, 0.01 * 60 * delta)
	else:
		global_position = lerp(global_position, left_target, 0.01 * 60 * delta)

func _on_Die_animation_finished():
	queue_free()

func _on_BombTimer_timeout():
	$BombTimer.wait_time = rand_range(3, 6)
	var bomb = Bomb.instance()
	get_parent().add_child(bomb)
	bomb.global_position = $BombSpawn.global_position
	bomb.enable()

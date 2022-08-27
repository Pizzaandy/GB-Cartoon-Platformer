extends RigidBody2D


func _ready():
	linear_velocity.y = rand_range(-200, 200)
	set_process(true)
	$ExplosionTimer.wait_time = rand_range(0.2, 2.5)

func _process(delta):
	$AnimatedSprite.modulate.g = $ExplosionTimer.time_left * 1.0 / $ExplosionTimer.wait_time
	$AnimatedSprite.modulate.b = $ExplosionTimer.time_left * 1.0 / $ExplosionTimer.wait_time
	if $Explosion.frame >= 4 || $Explosion.frame <= 7:
		$Area2D/CollisionShape2D.disabled = false
	else:
		$Area2D/CollisionShape2D.disabled = true

func explode():
	$AnimatedSprite.visible = false
	$Explosion.visible = true
	$Explosion.play("default")
	linear_velocity = Vector2(0,0)
	gravity_scale = 0
	
func _on_ExplosionTimer_timeout():
	explode()

func _on_Explosion_animation_finished():
	queue_free()

func _on_PlayerCollision_body_entered(body):
	if body.is_in_group("player"):
		explode()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.damage(1)

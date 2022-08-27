extends Area2D

var velocity = Vector2()
var grav = 0.1

func _ready():
	set_physics_process(false)

func enable():
	set_physics_process(true)

func _physics_process(delta):
	velocity.y += grav
	global_position += velocity
	if $Explosion.frame >= 4 || $Explosion.frame <= 7:
		$ExplosionArea/CollisionShape2D.disabled = false
	else:
		$ExplosionArea/CollisionShape2D.disabled = true

func _on_AnimatedSprite2_animation_finished():
	queue_free()

func _on_AlienBomb_body_entered(body):
	explode()
	$CollisionShape2D.disabled = true

func explode():
	velocity = Vector2(0, 0)
	grav = 0
	$Explosion.visible = true
	$AnimatedSprite.visible = false
	$Explosion.play("default")

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.damage(1)

extends Area2D

var velocity = Vector2()

func _ready():
	set_physics_process(false)

func launch(direction : Vector2, speed : float):
	velocity = direction.normalized() * speed
	set_physics_process(true)

func _physics_process(delta):
	global_position += velocity * delta

func _on_Lifetime_timeout():
	queue_free()

func _on_Projectile_body_entered(body):
	if body.is_in_group("enemy"):
		body.damage(1)
	queue_free()

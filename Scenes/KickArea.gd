extends Area2D

var defaultPosition
func _ready():
	defaultPosition = $CollisionShape2D.position.x

func _physics_process(delta):
	var is_flipped = get_parent().get_node("AnimatedSprite").flip_h
	if (!is_flipped):
		$CollisionShape2D.position.x = defaultPosition
	else:
		$CollisionShape2D.position.x = -defaultPosition
	

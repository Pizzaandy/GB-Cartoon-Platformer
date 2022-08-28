extends Area2D

var defaultPosition
var defaultFootPosition

func _ready():
	defaultPosition = $CollisionShape2D.position.x
	defaultFootPosition = $FootKickPosition.position.x

func _physics_process(delta):
	var is_flipped = get_parent().get_node("AnimatedSprite").flip_h
	if (!is_flipped):
		$CollisionShape2D.position.x = defaultPosition
		$FootKickPosition.position.x = defaultFootPosition
	else:
		$CollisionShape2D.position.x = -defaultPosition
		$FootKickPosition.position.x = -defaultFootPosition
	

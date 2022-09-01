extends Node2D

var soccerball_res = preload("res://Scenes/SoccerBall.tscn")
var confetti_res = preload("res://Confetti.tscn")

var soccerball_inst

var lscore = 0
var rscore = 0

onready var left_confetti_pos = $GoalLFront/GoalLConfettiAnchor
onready var right_confetti_pos = $GoalRFront/GoalRConfettiAnchor

func _ready():
	soccerball_inst = soccerball_res.instance()
	self.add_child(soccerball_inst)


func _on_GoalLArea_body_entered(body):
	if body.is_in_group("soccerball"):
		print("L triggered")
		var pos = left_confetti_pos.global_position
		var confetti_inst = confetti_res.instance()
		confetti_inst.rotate_rad = 1
		add_child(confetti_inst)
		confetti_inst.global_position = pos
		soccerball_inst.queue_free()
		soccerball_inst = soccerball_res.instance()
		self.add_child(soccerball_inst)
		lscore += 1


func _on_GoalRArea_body_entered(body):
	if body.is_in_group("soccerball"):
		print("R triggered")
		var pos = right_confetti_pos.global_position
		var confetti_inst = confetti_res.instance()
		confetti_inst.rotate_rad = -1
		add_child(confetti_inst)
		confetti_inst.global_position = pos
		rscore += 1
		soccerball_inst.queue_free()
		soccerball_inst = soccerball_res.instance()
		self.add_child(soccerball_inst)
		
	
func _process(delta):
	$Scores.text = str(lscore) + ":" + str(rscore)

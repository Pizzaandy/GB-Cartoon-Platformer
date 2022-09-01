extends Node2D

var soccerball_res = preload("res://Scenes/SoccerBall.tscn")
var confetti_res = preload("res://Confetti.tscn")

onready var left_confetti_pos = $GoalLFront/GoalLConfettiAnchor
onready var right_confetti_pos = $GoalRFront/GoalRConfettiAnchor

func _ready():
	self.add_child(soccerball_res.instance())
	pass
	


func _on_GoalLArea_body_entered(body):
	if body.is_in_group("soccerball"):
		print("L triggered")
		var pos = left_confetti_pos.global_position
		var confetti_inst = confetti_res.instance()
		confetti_inst.rotate_rad = 1
		add_child(confetti_inst)
		confetti_inst.global_position = pos
	


func _on_GoalRArea_body_entered(body):
	if body.is_in_group("soccerball"):
		print("R triggered")
		var pos = right_confetti_pos.global_position
		var confetti_inst = confetti_res.instance()
		confetti_inst.rotate_rad = -1
		add_child(confetti_inst)
		confetti_inst.global_position = pos
	

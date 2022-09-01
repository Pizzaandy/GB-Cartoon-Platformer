extends Node2D

var soccerball_res = preload("res://Scenes/SoccerBall.tscn")
var confetti_res = preload("res://Confetti.tscn")

var has_won = false

var soccerball_inst

var lscore = 0
var rscore = 0

var win_num = 2

onready var left_confetti_pos = $GoalLFront/GoalLConfettiAnchor
onready var right_confetti_pos = $GoalRFront/GoalRConfettiAnchor
onready var top_confetti_pos = $Ceiling/CeilingConfettiAnchor

onready var start_scene = "res://Start.tscn"

func _ready():
	soccerball_inst = soccerball_res.instance()
	self.add_child(soccerball_inst)


func _on_GoalLArea_body_entered(body):
	if body.is_in_group("soccerball") and not has_won:
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
		
		if lscore == win_num:
			win(true)
		
		


func _on_GoalRArea_body_entered(body):
	if body.is_in_group("soccerball") and not has_won:
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
	
		if rscore == win_num:
			win(false)
	
func _process(delta):
	if !has_won:
		$Scores.text = str(lscore) + ":" + str(rscore)

func win(is_left_win):
	has_won = true
	if is_left_win:
		$Scores.text = "Blue Won!"
	else:
		$Scores.text = "Pink Won!"

	var pos = top_confetti_pos.global_position
	var confetti_inst = confetti_res.instance()
	confetti_inst.rotate_rad = 0
	confetti_inst.one_shot = false
	confetti_inst.speed_multiplier = 1.5
	confetti_inst.size = 5
	confetti_inst.amount = 500
	add_child(confetti_inst)
	confetti_inst.global_position = pos
	
	$Camera2D.circle_wipe()
	


func _on_Camera2D_wipe_finished():
	get_tree().change_scene(start_scene)

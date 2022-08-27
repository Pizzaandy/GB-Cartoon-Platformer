extends Node2D

var soccerball_res = preload("res://Scenes/SoccerBall.tscn")


func _ready():
	self.add_child(soccerball_res.instance())
	pass

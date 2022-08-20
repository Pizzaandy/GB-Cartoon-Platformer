extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var currentViewportWidth = 0
var currentViewportHeight = 0


func _ready():
	currentViewportWidth = get_viewport().size.x
	currentViewportHeight = get_viewport().size.y
	resize_filmgrain_sprite()
	$Timer.wait_time = rand_range(5, 10)


func _process(_delta):
	#resize_filmgrain_sprite()
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	if currentViewportWidth != viewportWidth or viewportHeight != currentViewportHeight:
		resize_filmgrain_sprite()
		currentViewportWidth = viewportWidth
		currentViewportHeight = viewportHeight


var do_blur = false
var blur_speed = 0.04
var blur_amount = 0


func _physics_process(_delta):
	if do_blur == true:
		blur_amount += blur_speed * 1.1
	else:
		blur_amount -= blur_speed
	if blur_amount >= 0.8:
		do_blur = false
	blur_amount = clamp(blur_amount, 0.2, 0.8) + 0.1*rand_range(-1,1)


func resize_filmgrain_sprite():
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y

	var xscale = viewportWidth / 1440
	var yscale = viewportHeight / 1080
	
	get_node("AnimatedSprite").set_scale(Vector2(xscale, yscale))
	#get_node("ColorRect").set_size(Vector2(viewportWidth, viewportHeight))


func _on_AnimatedSprite_animation_finished():
	pass
	$AnimatedSprite.flip_h = not get_node("AnimatedSprite").flip_h
	#$AnimatedSprite.flip_v = choose_randomly([true, false])


func choose_randomly(list_of_entries):
	return list_of_entries[randi() % list_of_entries.size()]


func _on_AnimatedSprite_frame_changed():
	get_node("CanvasLayer/ColorRect").material.set_shader_param("blur_amount", blur_amount)


func _on_Timer_timeout():
	do_blur = true
	$Timer.wait_time = rand_range(5, 13)
	blur_speed = rand_range(0.02, 0.07)

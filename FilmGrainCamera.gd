extends Camera2D

var currentViewportWidth = 0
var currentViewportHeight = 0
var camera_wave_t = 0
export var bob_amount = 0

signal wipe_finished

var do_circle_wipe = false
var circle_size = 0

var last_circle_size = -1

func _ready():
	currentViewportWidth = get_viewport().size.x
	currentViewportHeight = get_viewport().size.y
	resize_filmgrain_sprite()
	$Timer.wait_time = rand_range(5, 10)


func _process(delta):
	#resize_filmgrain_sprite()
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	if currentViewportWidth != viewportWidth or viewportHeight != currentViewportHeight:
		resize_filmgrain_sprite()
		currentViewportWidth = viewportWidth
		currentViewportHeight = viewportHeight
	camera_wave_t = fmod(camera_wave_t + delta, 2*PI)
	position = Vector2(0, bob_amount * (sin(camera_wave_t)+1))
	
	if last_circle_size > 0 and circle_size == 0:
		emit_signal("wipe_finished")
	
	last_circle_size = circle_size
	


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
	blur_amount = clamp(blur_amount, 0.25, 0.8) + 0.1*rand_range(-1,1)


func resize_filmgrain_sprite():
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y

	var xscale = viewportWidth / 1440
	var yscale = viewportHeight / 1080
	
	var xscale2 = viewportWidth / 1280
	var yscale2 = viewportHeight / 720
	
	get_node("AnimatedSprite").set_scale(Vector2(xscale, yscale))
	get_node("Sprite").set_scale(Vector2(xscale2, yscale2))
	#get_node("ColorRect").set_size(Vector2(viewportWidth, viewportHeight))


func _on_AnimatedSprite_animation_finished():
	pass
	$AnimatedSprite.flip_h = not get_node("AnimatedSprite").flip_h
	#$AnimatedSprite.flip_v = choose_randomly([true, false])


func choose_randomly(list_of_entries):
	return list_of_entries[randi() % list_of_entries.size()]


func _on_AnimatedSprite_frame_changed():
	get_node("CanvasLayer/BlurPass").material.set_shader_param("blur_amount", blur_amount)
	if do_circle_wipe:
		circle_size = max(0, circle_size-0.04)
	else:
		circle_size = clamp(circle_size + 0.04, 0, 1.05)
	get_node("CanvasLayer/CircleWipe").material.set_shader_param("circle_size", circle_size)

func _on_Timer_timeout():
	do_blur = true
	$Timer.wait_time = rand_range(5, 13)
	blur_speed = rand_range(0.02, 0.07)
	

func circle_wipe():
	do_circle_wipe = true


func _on_HoleR_do_camera_wipe():
	circle_wipe()


func _on_HoleL_do_camera_wipe():
	circle_wipe()

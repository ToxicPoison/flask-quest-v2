extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

## Target speed for walking
@export var def_speed = 6.0

## Target speed for running
@export var run_speed = 6.0


@export var run_accel = 0.05
@export_range(0, 1) var def_friction = 0.1
@export_range(0, 1) var run_friction = 0.84
@export_range(0, 1) var rotation_speed = 0.2
@export var rotation_slowdown = 10.0
@export var anim_speed = 0.2


@onready var speed = def_speed
@onready var friction = def_friction
@onready var sprite = $Sprite

var running := false

var rot_speed_mod = 1 #Turning too sharply decreases this number

var input_direction := Vector2.ZERO
var force_dir := Vector2(0.0, 0.0)
var last_velocity := Vector3(1.0, 0.0, 0.0)

var moving := false

var input_dir_interp = Vector2.ZERO

var jumping := false

var landed := true
var jump_time := -10
@export var jump_vel_def := 6.0
var jump_vel := 0.0
@export var jump_falloff = 0.7
@export var jump_speed_multiplier_def = 2.0
@export var air_friction = 0.98
@export var air_speed = 0.5
var jump_spd := 1.0

var animation = "Toward"


func get_input():
	
	input_direction = Input.get_vector("left", "right", "up", "down")
	# Pushing up on the joystick will move the character away from the camera
	# Get the angle between the camera and the player
	# Get the currently active camera
	var camera = get_viewport().get_camera_3d()
	var camera_angle = -camera.global_transform.basis.y.normalized()
	var camera_angle_flattened = Vector2(camera_angle.x, camera_angle.z).normalized()
	var input_angle = camera_angle_flattened.angle()

	input_direction = input_direction.rotated(input_angle - PI/2)
	
	var run_input = Input.get_action_strength("run")
	var target_speed = lerpf(def_speed, run_speed, run_input)
	var target_friction = lerpf(def_friction, run_friction, run_input)
	
	
	##########################################################JUMPING
	
	if is_on_floor():
		jump_spd = 1.0
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_vel_def
		jump_spd = jump_speed_multiplier_def
		

		
	##########################################################
	
	
	#Actual speed and friction smoothly blend to the target speed/friction
	speed = lerpf(
		speed,
		target_speed * jump_spd,
		run_accel
	)
	friction = lerpf(
		friction,
		target_friction,
		run_accel
	)

	if not is_on_floor():
		friction = air_friction
		speed = air_speed
	
	
	if input_direction.length() > 0.1:
		moving = true
		
		var lerp_ang = lerp_angle(input_dir_interp.angle(), input_direction.angle(), rotation_speed)
		input_dir_interp = Vector2.from_angle(lerp_ang) * input_direction.length()
		var angle_diff = abs(input_dir_interp.angle_to(input_direction))
		rot_speed_mod = pow(1 - (angle_diff / (2*PI)), rotation_slowdown)
		
		force_dir = input_dir_interp * speed * rot_speed_mod
	
	else:
		moving = false
		force_dir = Vector2.ZERO
	
#	print(friction)
#	print(speed)
#	print("..")
	velocity = (velocity*(Vector3(friction, 1.0, friction)) + Vector3(force_dir.x, 0, force_dir.y))
	last_velocity = velocity






func animate():
	var camera = get_viewport().get_camera_3d()
	var cam_pos_flat = Vector2(camera.global_position.x, camera.global_position.z)
	var pos_flat = Vector2(global_position.x, global_position.z)
	var view_angle = cam_pos_flat.angle_to_point(pos_flat)
	
	#7.0 is added only to prevent the x value in fmod from becoming negative.
	#7.0 is odd in this case to flip the angle around
	#(An even number in this case would yield a full number of revolutions
	var r = (fmod(7.0 + view_angle/PI - input_dir_interp.angle()/PI, 2.0) - 1.0) * 8.0
	
#	print(r)
#	print(view_angle/PI)
#	print(input_dir_interp.angle()/PI)
#	print("..")
	
	if r >= -1 && r <= 1:
		animation = "Away"
	elif r >= 1 && r <= 3:
		animation = "AL"
	elif r >= 3 && r <= 5:
		animation = "Left"
	elif r >= 5 && r <= 7:
		animation = "TL"
	elif r >= -3 && r <= -1:
		animation = "AR"
	elif r >= -5 && r <= -3:
		animation = "Right"
	elif r >= -7 && r <= -5:
		animation = "TR"
	else:
		animation = "Toward"
	
	if moving && is_on_floor():
		sprite.speed_scale = velocity.length() * anim_speed
	else:
		sprite.speed_scale = 0
		sprite.frame = 0
		animation += "Idle"
		
	sprite.animation = animation
	
	
	






func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
#
	get_input()
	animate()
	move_and_slide()
	

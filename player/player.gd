extends CharacterBody2D

## Wonderulf Descripo
@export var def_speed = 100.0; 

## I love documentation.
@export var run_speed = 50.0;

@export var run_accel = 0.05;
@export_range(0, 1) var def_friction = 0.1;
@export_range(0, 1) var run_friction = 0.84;
@export_range(0, 1) var rotation_speed = 0.2; #ideally 0<x<1
@export var rotation_slowdown = 5.0;

@onready var speed = def_speed
@onready var friction = def_friction
@onready var sprite = $YOffset/AnimatedSprite2D
@onready var shadow = $Shadow

var running := false


var rot_speed_mod = 1; #Turning too sharply decreases this number

var input_direction := Vector2.ZERO
var force_dir := Vector2(0.0, 0.0);
var last_velocity := Vector2(1.0, 0.0);

var moving := false

var input_dir_interp = Vector2.ZERO

var jumping := false

var landed := true
var jump_time := -10
@export var jump_vel_def := 60.0
var jump_vel := 0.0
@export var jump_falloff = 0.7
@export var jump_speed_multiplier_def = 2.0
var jump_spd := 1.0

var paint_mod := 1.0

func get_input():
	
	##########################################################JUMPING
	
	if Input.is_action_just_pressed("jump") && landed:
		jumping = true
		jump_vel = jump_vel_def ################!!!!!!
		landed = false
		jump_spd = jump_speed_multiplier_def
		
	elif Input.is_action_just_released("jump"):
#		jumping = false
		jump_vel = jump_vel*0.1
		
		
	if jumping:
		jump_time += 1
		jump_vel *= jump_falloff
		sprite.position -= Vector2(0, jump_vel)
		if jump_vel < 0.2:
			jumping = false
		
	
	elif !landed:
		jump_time -= 1
		jump_vel *= 1/jump_falloff
		if sprite.position.y + jump_vel >= 0.0: ######!!!!!!
			landed = true
			sprite.position = Vector2.ZERO
			jump_spd = 1.0
			return
		sprite.position += Vector2(0, jump_vel)
		
		
		
	##########################################################RUNNING
			
	shadow.position = Vector2(-sprite.position.y / 4, 0)
	
	
	
	input_direction = Input.get_vector("left", "right", "up", "down")
	
	force_dir = input_dir_interp * speed * rot_speed_mod
	
	var run_input = Input.get_action_strength("run")

	var target_speed = lerpf(def_speed, run_speed, run_input)
	var target_friction = lerpf(def_friction, run_friction, run_input)
	
	speed = lerpf(
		speed,
		target_speed * jump_spd * paint_mod,
		run_accel
	)
	friction = lerpf(
		friction,
		target_friction,
		run_accel
	)
		
	
	if input_direction.length() > 0.1:
		moving = true
		
		var lerp_ang = lerp_angle(input_dir_interp.angle(), input_direction.angle(), rotation_speed)
		input_dir_interp = Vector2.from_angle(lerp_ang) * input_direction.length()
		
#		var angle_diff = abs(fmod(input_dir_interp.angle(), 2*PI) - fmod(input_direction.angle(), 2*PI))
		var angle_diff = abs(input_dir_interp.angle_to(input_direction))
#		print(fmod(input_dir_interp.angle(), 2*PI))
#		print(fmod(input_direction.angle(), 2*PI))
#		print(angle_diff)
#		print(angle_diff / (2*PI))
		
#		if angle_diff > 0:
		rot_speed_mod = pow(1 - (angle_diff / (2*PI)), rotation_slowdown)
#		print(rot_speed_mod)
#		print("------------------------------")

	else:
		moving = false
		force_dir = Vector2.ZERO
	
	
	
	
	velocity = (velocity*(friction) + force_dir)
	
	
	$RotRef.rotation = input_dir_interp.angle()
	$RotRefREAL.rotation = input_direction.angle()
	
		
	last_velocity = velocity
	

	

	
	
	
	
	
	
	
	
func animate():
	var r = fmod(input_dir_interp.angle(), (2*PI)) / (0.25 * PI)
	
	if moving:
		sprite.speed_scale = velocity.length() / 400.0
	else:
		sprite.speed_scale = 0
		sprite.frame = 0
	
	if r <= 1 && r >= -1:
		sprite.animation = "E"
#	elif r >= -1.5 && r <= -0.5:
#		sprite.animation = "NE"
	elif r >= -3 && r <= -1:
		sprite.animation = "N"
#	elif r >= -3.5 && r <= -2.5:
#		sprite.animation = "NW"
#	elif r >= 0.5 && r <= 1.5:
#		sprite.animation = "SE"
	elif r >= 1 && r <= 3:
		sprite.animation = "S"
#	elif r >= 2.5 && r <= 3.5:
#		sprite.animation = "SW"
	else:
		sprite.animation = "W"
	

func _ready():
	sprite.play()

func _physics_process(delta):

	get_input()
	animate()
	
	move_and_slide()


extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

## Target speed for walking
@export var walk_speed = 4.0
## Target speed for running
@export var run_speed = 3.0
## Friction when walking
@export_range(0, 1) var walk_friction = 0.04
## Friction when running
@export_range(0, 1) var run_friction = 0.7
## Target speed when jumping
@export var air_speed = 0.1
@export var run_air_speed = 0.3
## Friction when jumping
@export var air_friction = 0.99
@export var run_air_friction = 0.99
## Vertical speed you jump at
@export var jump_vel_def := 5.0

@export var anim_speed_scale = 0.2

@onready var sprite = $Sprite
@onready var ledge_jump_timer = $LedgeJumpTimeout
var ledge_jump_time := 0.5
@onready var audio_footstep = $FootstepAudio
@onready var audio_impact = $ImpactAudio

var running := false

var input_direction := Vector2.ZERO
var force_dir := Vector2(0.0, 0.0)
var last_velocity := Vector3(1.0, 0.0, 0.0)

var moving := false
var jumping := false
var jump_override := false # If true, player can jump while in the air
var was_in_air := false

var animation = "Toward"

@onready var camera : Object = get_viewport().get_camera_3d()
var camera_forward := Vector3.ZERO
var view_angle : float = 0.0
var facing : float = 0.0 # The angle the player is facing. Based on the direction they last moved.

func get_input():
	
	input_direction = Input.get_vector("left", "right", "up", "down")
	# Pushing up on the joystick will move the character away from the camera
	
	# Rotate the direction the player moves based on the camera angle
	input_direction = input_direction.rotated(view_angle + PI/2)
	
	var run_input = Input.get_action_strength("run")
	var speed = lerpf(walk_speed, run_speed, run_input)
	var friction = lerpf(walk_friction, run_friction, run_input)
	
	##########################################################JUMPING
	
	if not is_on_floor():
		if not was_in_air and not jumping:
			jump_override = true
			ledge_jump_timer.start()
		was_in_air = true
		# Use air speed/friction values instead of regular speed/friction values
		friction = lerpf(air_friction, run_air_friction, run_input)
		speed = lerpf(air_speed, run_air_speed, run_input)
	
	if was_in_air and is_on_floor():
		jumping = false
		was_in_air = false
		audio_impact.volume_db = minf(absf(get_real_velocity().y) * 5.0 - 20.0, -10.0)
		audio_impact.play()
		$AnimationPlayer.play("land")
			
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_override):
		velocity.y = jump_vel_def
		jumping = true
		audio_footstep.play()
		
		
	##########################################################

	if input_direction.length() > 0.1:
		facing = input_direction.angle()/PI
		force_dir = input_direction * speed
		moving = true
	
	else:
		moving = false
		force_dir = Vector2.ZERO

	velocity = (velocity*(Vector3(friction, 1.0, friction)) + Vector3(force_dir.x, 0, force_dir.y))
	last_velocity = velocity



func animate():
	
	#7.0 is added only to prevent the x value in fmod from becoming negative.
	#7.0 is odd in this case to flip the angle around
	#(An even number in this case would yield a full number of revolutions
	var r = (fmod(7.0 + view_angle/PI - facing, 2.0) - 1.0) * 8.0
	
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
		sprite.speed_scale = velocity.length() * anim_speed_scale
	else:
		sprite.speed_scale = 0
		sprite.frame = 0
		animation += "Idle"
		
	sprite.animation = animation
	

func on_frame_changed():
	match sprite.frame:
		0,2:
			audio_footstep.play()


func ledge_jump_timeout():
	jump_override = false


func _ready():
	sprite.connect("frame_changed", on_frame_changed)
	ledge_jump_timer.connect("timeout", ledge_jump_timeout)


func _physics_process(delta):
	$DebugLabel.text = String.num_int64(minf(absf(get_real_velocity().y) * 5.0 - 20.0, -10.0))
	# Calculate the player's view angle
	# This effects the direction the player moves and which sprites they appear as
	if camera:
		camera_forward = camera.global_transform.basis.z
	view_angle = Vector2(camera_forward.x, camera_forward.z).angle() - PI
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
#
	get_input()
	animate()
	move_and_slide()
	

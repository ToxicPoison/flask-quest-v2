extends SpringArm3D


var mouse_sens := 0.002
var joystick_sens := 3.0
# This is in addition to the camera's initial rotation:
var min_pitch_deg := -25 # Negative = looking down.
var max_pitch_deg := 50

var cam_min_pitch_deg := -70
var cam_max_pitch_deg := 70
var rig_rot_speed := 0.8
var rig_follow_speed := 0.3
var cam_rot_speed = 1.0
var y_offset := 3.0

# VARIABLES USED IN CONTROLLER MODE CAMERA:

var last_position := Vector3.ZERO
var horiz_angle := 0.0
var smoothed_horiz_angle := 0.0
var controller_rig_rot_speed := 0.04
var to := Vector2.ZERO
var remembered_position := Vector2.ZERO
var last_remembered_position := Vector2.ZERO
## In controller mode, the camera will change angle once the player this
## distance.
var distance_until_angle_change := 2.0

## What the camera orbits around (can be any 3D node)
@export var cam_target = get_parent()
## In controller mode, the camera points in the direction it is moving in but
## can be rotated around the "forward direction" a little.
@export var controller_mode := false
@onready var all_rot = rotation
@onready var target_pos = position
@onready var target_rot = rotation
@onready var cam_target_rot = rotation
@onready var camera = $CamPos

func _ready():
	set_as_top_level(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	remembered_position = Vector2(position.x, position.y)

func _unhandled_input(event):
	if event is InputEventMouseMotion and not controller_mode:
		target_rot.y -= event.relative.x * mouse_sens
		target_rot.y = wrapf(target_rot.y,0.0,TAU)
		
		target_rot.x -= event.relative.y * mouse_sens
		target_rot.x = clamp(target_rot.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
		
		
		
	if event.is_action_pressed("ui_cancel"):
		var i = Input.MOUSE_MODE_VISIBLE
		if Input.mouse_mode == i:
			i = Input.MOUSE_MODE_CAPTURED
		Input.mouse_mode = i

func controller_input(delta):
	var direction = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	var pos_flat = Vector2(position.x, position.z)
	if remembered_position.distance_to(pos_flat) > distance_until_angle_change:
		to = (remembered_position - pos_flat).normalized() * distance_until_angle_change * 0.5
		to += pos_flat
	remembered_position = remembered_position.lerp(to, 0.1)
	
	if remembered_position.distance_squared_to(last_remembered_position) > 0.001:
		horiz_angle = -remembered_position.angle_to_point(last_remembered_position) + PI/2
	
	smoothed_horiz_angle = lerp_angle(smoothed_horiz_angle, horiz_angle, controller_rig_rot_speed)
	
	if absf(direction.x) > 0.1:
		var angle_change : float = direction.x * joystick_sens * delta
		horiz_angle -= angle_change
		smoothed_horiz_angle -= angle_change
		
	target_rot.y = smoothed_horiz_angle
	
	last_remembered_position = remembered_position
	
	target_rot.x -= direction.y * joystick_sens * delta
	target_rot.x = clamp(target_rot.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))

func _physics_process(delta):
	
	rotation.y = lerp_angle(rotation.y, target_rot.y, rig_rot_speed)
	rotation.x = lerp_angle(rotation.x, target_rot.x, rig_rot_speed)
#	camera.rotation.x = lerp_angle(camera.rotation.x, cam_target_rot.x, cam_rot_speed)
	
	target_pos = (cam_target.global_transform.origin + Vector3(0,y_offset,0))
	position = lerp(position, target_pos, rig_follow_speed)

	if controller_mode:
		controller_input(delta)

	last_position = target_pos
	$MeshInstance3D.global_position = Vector3(remembered_position.x, 1.0, remembered_position.y)

extends SpringArm3D


var mouse_sens := 0.01
var min_pitch_deg := -25
var max_pitch_deg := 25
var cam_min_pitch_deg := -70
var cam_max_pitch_deg := 70
var rig_rot_speed := 0.8
var rig_follow_speed := 0.3
var cam_rot_speed = 1.0
var y_offset := 3.0

@export var cam_target = get_parent()
@onready var all_rot = rotation
@onready var target_pos = position
@onready var target_rot = rotation
@onready var cam_target_rot = rotation
@onready var camera = $CamPos

func _ready():
	set_as_top_level(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event is InputEventMouseMotion:
		target_rot.y -= event.relative.x * mouse_sens
		target_rot.y = wrapf(target_rot.y,0.0,TAU)
		
		target_rot.x -= event.relative.y * mouse_sens
		target_rot.x = clamp(target_rot.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
#		target_rot = Vector2(clamp(all_rot.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg)), all_rot.y)
#		if all_rot.x > deg_to_rad(max_pitch_deg):
#			cam_target_rot.x = all_rot.x - cam_max_pitch_deg
#		elif all_rot.x < deg_to_rad(min_pitch_deg):
#			cam_target_rot.x = all_rot.x + cam_min_pitch_deg
		
		
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta):
	rotation.y = lerp_angle(rotation.y, target_rot.y, rig_rot_speed)
	rotation.x = lerp_angle(rotation.x, target_rot.x, rig_rot_speed)
#	camera.rotation.x = lerp_angle(camera.rotation.x, cam_target_rot.x, cam_rot_speed)
	
	target_pos = (cam_target.global_transform.origin + Vector3(0,y_offset,0))
	position = lerp(position, target_pos, rig_follow_speed)

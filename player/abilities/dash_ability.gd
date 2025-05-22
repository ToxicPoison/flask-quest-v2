extends Node

var player : Player = null
var can_dash := false
var forward_force := 4.0
var up_force := 2.0

func _ready():
	player = get_parent()
	
func _physics_process(delta):
	if Input.is_action_just_pressed("jump") and can_dash and !player.can_jump:
		var horizontal := Vector2(forward_force, 0.0).rotated(player.facing)
		player.velocity += Vector3(horizontal.x, up_force, horizontal.y)
		can_dash = false
		$GPUParticles3D.restart()
		$AudioStreamPlayer3D.play()
	if player.is_on_floor() and !can_dash:
		can_dash = true

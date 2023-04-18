extends Node2D


var shooting = false
var player

var spread = 0.05;

@onready var visual = $Visual
var fall_dist := -0.01

func _ready():
	player = get_parent()

func get_input():
	if Input.is_action_just_pressed("jump"):
		shooting = true
		$Timer.start(0)
		
	elif Input.is_action_just_released("jump"):
		shooting = false
		$Timer.stop()


func shoot():
	var bullet = preload("res://weapons/painter/Pellet.tscn").instantiate()
	
	
	bullet.position = player.position
	bullet.travel_dir = player.input_dir_interp.angle() + randf_range(-spread, spread)
	bullet.speed_addend = player.velocity
	bullet.speed = 500.0
	
	get_tree().get_root().add_child(bullet)
	


func _physics_process(delta):
	get_input()


func _on_timer_timeout():
	shoot()

func _process(delta):
	visual.rotation = player.input_dir_interp.angle()

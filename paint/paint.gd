extends Node2D

@export_node_path("CharacterBody2D") var player_path
@onready var player = get_node(player_path)

@export_node_path var splat_path
@onready var splat = get_node(splat_path)
@onready var splat_tex = preload("res://paint/splat.png")
@onready var transparent_tex = preload("res://paint/transparent.png")
@onready var default_scale = splat.scale

@onready var viewport_tex = $SubViewportContainer/SubViewport.get_texture()

@export var paint_color := Color(0.8, 0.1, 0.8, 1.0)

var painting := false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		painting = true
		splat.texture = splat_tex
		
	elif Input.is_action_just_released("jump"):
		painting = false
		splat.texture = transparent_tex
		
	if painting:
		splat.modulate = paint_color
		splat.position = (player.position - position)
		splat.rotation = randf_range(0, 2*PI)
		splat.scale = default_scale * (1 / ((player.velocity.length()/1000 + 1)))
		
	detect_player()
	
func detect_player():
	var viewport_img = viewport_tex.get_image()
	var col = viewport_img.get_pixelv(player.position)
	if col.a >= 0.5:
		player.paint_mod = 2.0
	else:
		player.paint_mod = 1.0

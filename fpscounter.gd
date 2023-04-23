extends Control

@onready var label = $Label

func _init():
	pass

func _process(delta):
	label.text = str(Engine.get_frames_per_second())

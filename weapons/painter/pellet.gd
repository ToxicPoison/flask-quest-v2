extends Area2D

@export var speed := 100
var speed_addend := Vector2.ZERO
@export var speed_change := 1
var vec 

var travel_dir := 0.0

@onready var visual = $Visual
var fall_dist := -0.01

func _process(delta):
	vec = Vector2(speed, 0).rotated(travel_dir) + speed_addend
	position += vec * delta
	speed *= speed_change
	
#	fall_dist *= 1.1 * delta * 100.0
#	visual.position += Vector2(0, fall_dist)

	if (visual.position.y >= -0.01):
		hit_surface()



func _on_body_entered(body):
	if !body.is_in_group("player"):
		hit_surface()
	
func hit_surface():
	self.queue_free()
	emit_signal("smack")

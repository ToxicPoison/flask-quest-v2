extends Area2D

@export var speed := 100
var speed_addend := Vector2.ZERO
@export var speed_change := 1
var vec 



func _process(delta):
	vec = Vector2(speed, 0).rotated(rotation) + speed_addend
	position += vec * delta
	speed *= speed_change


func _on_body_entered(body):
	if !body.is_in_group("player"):
		self.queue_free()
	

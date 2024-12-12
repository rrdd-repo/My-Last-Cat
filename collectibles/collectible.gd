class_name Collectible
extends Area2D

@export var value: int = 1
signal collected(character)

func _on_body_entered(body):
	if body.is_in_group("Collector"):
		collect(body)

func collect(character):
	emit_signal("collected", character)
	queue_free()

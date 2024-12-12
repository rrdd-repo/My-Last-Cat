class_name EndLevel
extends Area2D

@export var scene_to_change: PackedScene
@onready var end_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var homing_close_door: bool = true
@export var following_close_door: bool = false
var is_door_open: bool = false

signal level_ended(scene_to_change: PackedScene)
signal door_state_changed(is_open: bool)

func _ready() -> void:
	# On game start, partner is following (better not to hardcode it like this but)
	# It'd be cool if in a real game we made it so there are also other ways to finish the level (like killing an enemy, etc)
	partner_state_changed(0)

# This is not checking every frame, might wanna change this idea lol
func partner_state_changed(new_state: int) -> void:
	if new_state == Partner.PartnerState.HOMING and homing_close_door:
		set_door_closed()
	elif new_state == Partner.PartnerState.FOLLOWING and following_close_door:
		set_door_closed()
	else:
		set_door_open()
		
func set_door_closed() -> void:
	end_sprite.play("closed")
	is_door_open = false
	emit_signal("door_state_changed", is_door_open)

func set_door_open() -> void:
	end_sprite.play("open")
	is_door_open = true
	emit_signal("door_state_changed", is_door_open)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and is_door_open:
		emit_signal("level_ended", scene_to_change)

class_name LevelManager
extends Node2D

var partner: Partner
var player: Player
var is_paused: bool = false

signal pause_toggled(is_paused: bool)
signal game_over

func _on_player_death() -> void:
	emit_signal("game_over")

func reset() -> void:
	if get_tree().current_scene != null:
		if partner != null:
			partner.call_deferred("reset")
		get_tree().call_deferred("reload_current_scene")

func _ready() -> void:
	Engine.time_scale = 1
	player = get_node('Player')
	partner = get_node('Partner')
	
	player.is_dead.connect(_on_player_death)
	
	if partner:
		partner.state_changed.connect(_on_partner_state_changed)


func _on_partner_state_changed(new_state: int) -> void:
	var end_level_nodes = get_tree().get_nodes_in_group("EndLevel")
	for end_level in end_level_nodes:
		if end_level is EndLevel:
			end_level.partner_state_changed(new_state)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset") and get_tree().current_scene != null:
		reset()
		
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		_update_pause_state()

func _update_pause_state() -> void:
	get_tree().paused = is_paused
	emit_signal("pause_toggled", is_paused)

func unpause_game() -> void:
	is_paused = false
	_update_pause_state()

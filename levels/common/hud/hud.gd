class_name Hud
extends Control

var timer_value: float = 0.0
var next_scene: PackedScene = null

@onready var speedrun_timer: Label = $SpeedrunPanel/SpeedrunTimer
@onready var player_health_bar: ProgressBar = $PlayerHealthBar
@onready var partner_health_bar: ProgressBar = $PartnerHealthBar
@onready var partner_condition_bar: ProgressBar = $PartnerConditionBar
@onready var unbeatable_label: Label = $UnbeatableLabel

@onready var level_complete_node: Control = $LevelComplete
@onready var pause_menu_node: Control = $PauseMenu
@onready var game_over_node: Control = $GameOver

var level_manager: LevelManager
var player: Player
var partner: Partner

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as Player
		player.health_changed.connect(_on_player_health_changed)
		player_health_bar.max_value = player.max_health
		player_health_bar.value = player.max_health - player.health

	var partners = get_tree().get_nodes_in_group("Partner")
	if partners.size() > 0:
		partner = partners[0] as Partner
		partner.health_changed.connect(_on_partner_health_changed)
		partner_health_bar.max_value = partner.max_health
		partner_health_bar.value = partner.max_health - partner.health

		if partner.partner_condition != null:
			partner.partner_condition.progress_changed.connect(_on_partner_condition_changed)
			partner_condition_bar.max_value = 100
			partner_condition_bar.value = partner.partner_condition.get_progress() * 100
	else:
		partner_condition_bar.hide()
	
	# For Level Complete
	var end_levels = get_tree().get_nodes_in_group("EndLevel")
	for end_level in end_levels:
		end_level.level_ended.connect(_on_EndLevel_level_ended)
		end_level.door_state_changed.connect(_on_EndLevel_door_state_changed)
	
	# For PauseMenu
	for child in get_tree().root.get_children():
		if child is LevelManager:
			level_manager = child
			break
	
	if level_manager != null:
		level_manager.pause_toggled.connect(_on_pause_toggled)
		level_manager.game_over.connect(_on_game_over)
		
	unbeatable_label.visible = false

func _process(delta: float) -> void:
	# Update the speedrun timer
	timer_value += delta
	speedrun_timer.text = format_time(timer_value)

	# Update partner condition progress
	if partner != null and partner.partner_condition != null:
		partner_condition_bar.value = partner.partner_condition.get_progress() * 100

func _on_player_health_changed(new_health: int) -> void:
	player_health_bar.value = new_health

func _on_partner_health_changed(new_health: int) -> void:
	partner_health_bar.value = new_health

func _on_partner_condition_changed(new_progress: float) -> void:
	partner_condition_bar.value = new_progress * 100

func format_time(time_value: float) -> String:
	var minutes = int(time_value) / 60
	var seconds = int(time_value) % 60
	var milliseconds = int((time_value - int(time_value)) * 100)
	return "%dm%02ds%02dms" % [minutes, seconds, milliseconds]
	
func _on_EndLevel_level_ended(scene_to_change: PackedScene) -> void:
	get_tree().paused = true
	next_scene = scene_to_change
	level_complete_node.visible = true

func _on_pause_toggled(is_paused: bool) -> void:
	pause_menu_node.visible = is_paused

func _on_game_over() -> void:
	game_over_node.visible = true
	get_tree().paused = true

func _on_next_level_button_pressed() -> void:
	if next_scene != null:
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_scene)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://misc/main_menu/main_menu.tscn")

func _on_resume_button_pressed() -> void:
	if level_manager != null:
		level_manager.unpause_game()

func _on_restart_button_pressed() -> void:
	partner.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_pause_menu_visibility_changed() -> void:
	if pause_menu_node.visible:
		var resume_button = pause_menu_node.get_node("Panel/ResumeButton") as Button
		resume_button.grab_focus()


func _on_level_complete_visibility_changed() -> void:
	if level_complete_node.visible:
		var next_level_button = level_complete_node.get_node("Panel/NextLevelButton") as Button
		next_level_button.grab_focus()


func _on_game_over_visibility_changed() -> void:
	if game_over_node.visible:
		var restart_button = game_over_node.get_node("Panel/RestartButton") as Button
		restart_button.grab_focus()
		
func _on_EndLevel_door_state_changed(is_open: bool) -> void:
	unbeatable_label.visible = not is_open

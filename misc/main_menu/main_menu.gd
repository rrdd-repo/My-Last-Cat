class_name MainMenu
extends Control

func _ready() -> void:
	$CreditsWindow/Credits.close_requested.connect(_on_credits_close_requested)
	$HowToPlayWindow/HowToPlay.close_requested.connect(_on_how_to_play_close_requested)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/tutorial_level/tutorial.tscn")

func _on_credits_close_requested() -> void:
	$CreditsWindow.hide()

func _on_credits_pressed() -> void:
	$CreditsWindow.show()

func _on_how_to_play_pressed() -> void:
	$HowToPlayWindow.show()

func _on_how_to_play_close_requested() -> void:
	$HowToPlayWindow.hide()

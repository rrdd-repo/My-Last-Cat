class_name CongratulationsLevel
extends Control


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://misc/main_menu/main_menu.tscn")

class_name Credits
extends Control

signal close_requested

func _on_close_button_pressed() -> void:
	emit_signal("close_requested")


func _on_visibility_changed() -> void:
	$CloseButton.grab_focus()

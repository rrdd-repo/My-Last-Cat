class_name PartnerCondition
extends Resource

signal progress_changed(new_progress)

func is_met(delta: float) -> bool:
	return false
	
func get_progress() -> float:
	return 0.0
	
func adjust_progress(amount: int) -> void:
	emit_signal("progress_changed", get_progress())

func reset() -> void:
	pass

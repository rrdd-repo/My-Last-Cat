class_name JumpCountCondition
extends PartnerCondition

@export var jump_threshold: int = 10
var jump_count: int = 0

func is_met(delta: float) -> bool:
	return jump_count >= jump_threshold

func on_character_jump():
	jump_count += 1

func get_progress() -> float:
	return clamp(float(jump_count) / jump_threshold, 0.0, 1.0)
	
func adjust_progress(amount: int) -> void:
	super.adjust_progress(amount)
	jump_count = clamp(jump_count + amount, 0, jump_threshold)

func reset() -> void:
	jump_count = 0

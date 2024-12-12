class_name TimeBasedCondition
extends PartnerCondition

@export var time_before_homing: float = 5.0
var elapsed_time: float = 0.0

func is_met(delta: float) -> bool:
	elapsed_time += delta
	return elapsed_time >= time_before_homing

func get_progress() -> float:
	return clamp(elapsed_time / time_before_homing, 0.0, 1.0)

func adjust_progress(amount: int) -> void:
	super.adjust_progress(amount)
	elapsed_time = clamp(elapsed_time + float(amount), 0.0, time_before_homing)

func reset() -> void:
	elapsed_time = 0.0

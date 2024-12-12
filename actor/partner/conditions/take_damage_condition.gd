class_name TakeDamageCondition
extends PartnerCondition

@export var damage_threshold: int = 10
var accumulated_damage: int = 0

var actor_to_track: Actor

func is_met(delta: float) -> bool:
	return accumulated_damage >= damage_threshold

func get_progress() -> float:
	return clamp(float(accumulated_damage) / damage_threshold, 0.0, 1.0)

func on_character_hit(damaged_actor: Actor) -> void:
	if damaged_actor == actor_to_track:
		accumulated_damage += 1

func adjust_progress(amount: int) -> void:
	super.adjust_progress(amount)
	accumulated_damage = clamp(accumulated_damage - amount, 0, damage_threshold)

# Reset method for this condition
func reset() -> void:
	accumulated_damage = 0

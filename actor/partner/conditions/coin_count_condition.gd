class_name CoinCountCondition
extends PartnerCondition

@export var required_coins: int = 10
var collected_coins: int = 0

func is_met(delta: float) -> bool:
	return collected_coins >= required_coins

func on_coin_collected():
	collected_coins += 1

func get_progress() -> float:
	return float(collected_coins) / required_coins

func adjust_progress(amount: int) -> void:
	super.adjust_progress(amount)
	collected_coins = clamp(collected_coins + amount, 0, required_coins)

func reset() -> void:
	collected_coins = 0

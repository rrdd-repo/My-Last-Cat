class_name HealthPickup
extends Collectible

@export var amount: int = 1

func collect(character):
	character.on_health_collected(amount)
	super.collect(character)

class_name Coin
extends Collectible

func collect(character):
	character.on_coin_collected()
	super.collect(character)
	

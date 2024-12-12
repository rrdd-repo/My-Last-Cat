class_name PartnerConditionSwitch
extends Area2D

@export var reset_condition: bool = false
@export_category("Elements that will be switched")
@export var new_condition: PartnerCondition
@export var partner_to_switch: Partner
@export_category("Actor that activates the switch")
# Actor that will need to touch the area to activate it
@export var tracked_actor: Actor

func change_partner_condition() -> void:
	# Store the old condition's progress before disconnecting
	var old_progress: float = 0.0
	if partner_to_switch.partner_condition != null:
		old_progress = partner_to_switch.partner_condition.get_progress()
	
	# Disconnect the old condition
	if partner_to_switch.partner_condition != null and partner_to_switch.actor_to_track != null:
		if partner_to_switch.partner_condition is JumpCountCondition:
			if partner_to_switch.actor_to_track.jumped.is_connected(
				partner_to_switch.partner_condition.on_character_jump):
				partner_to_switch.actor_to_track.jumped.disconnect(
					partner_to_switch.partner_condition.on_character_jump)
		
		elif partner_to_switch.partner_condition is CoinCountCondition:
			if partner_to_switch.actor_to_track.coin_collected.is_connected(
				partner_to_switch.partner_condition.on_coin_collected):
				partner_to_switch.actor_to_track.coin_collected.disconnect(
					partner_to_switch.partner_condition.on_coin_collected)
		
		elif partner_to_switch.partner_condition is TakeDamageCondition:
			var take_damage_condition = partner_to_switch.partner_condition as TakeDamageCondition
			if partner_to_switch.actor_to_track.got_damaged.is_connected(
				take_damage_condition.on_character_hit):
				partner_to_switch.actor_to_track.got_damaged.disconnect(
					take_damage_condition.on_character_hit)
	
	# Reset the old condition
	if partner_to_switch.partner_condition != null and reset_condition:
		partner_to_switch.switch_sfx.play_sound(partner_to_switch.position, "SFX")
		partner_to_switch.partner_condition.reset()
	
	# Assign new condition and actor
	partner_to_switch.partner_condition = new_condition
	partner_to_switch.actor_to_track = tracked_actor
	
	if not reset_condition and new_condition != null:
		if new_condition is TimeBasedCondition:
			var time_condition = new_condition as TimeBasedCondition
			var time_amount = int(round(old_progress * time_condition.time_before_homing))
			time_condition.adjust_progress(time_amount)
		
		elif new_condition is JumpCountCondition:
			var jump_condition = new_condition as JumpCountCondition
			var jump_amount = int(round(old_progress * jump_condition.jump_threshold))
			jump_condition.adjust_progress(jump_amount)
			
		# Convert the progress percentage to the appropriate amount for each condition type
		elif new_condition is CoinCountCondition:
			var coin_condition = new_condition as CoinCountCondition
			var coin_amount = int(round(old_progress * coin_condition.required_coins))
			coin_condition.adjust_progress(coin_amount)
		
		elif new_condition is TakeDamageCondition:
			var damage_condition = new_condition as TakeDamageCondition
			var damage_amount = int(round(old_progress * damage_condition.damage_threshold))
			damage_condition.adjust_progress(damage_amount)

	# Reconnect signals for the new condition
	partner_to_switch.setup_condition_connections()


func _on_body_entered(body: Node2D) -> void:
	if body == tracked_actor and partner_to_switch != null:
		change_partner_condition()

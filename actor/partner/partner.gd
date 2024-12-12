class_name Partner
extends Actor

#region Nodes
@onready var partner_sprite: Sprite2D = $Sprite2D
@onready var partner_hitbox: Area2D = $Boxes/PartnerHitbox
@onready var pause_timer: Timer = $Timer
#endregion

#region General
@export var damage: int = 1
@export var player_path: NodePath
var player: Player
#endregion

#region Partner States
enum PartnerState { FOLLOWING, HOMING, PAUSED }
var state: int = PartnerState.FOLLOWING
signal state_changed(new_state)
@export var partner_condition: PartnerCondition
@export var actor_to_track: Actor
var homing_triggered: bool = false
#endregion

#region Movement
@export var follow_distance: float = 100.0 
@export var homing_speed: float = 800.0
@export var max_distance: float = 500.0
@export var pause_duration: float = 1.0
#endregion

#region Aesthetics
@onready var land_particles: CPUParticles2D = $Particles/LandParticles
@onready var ghost_particles: CPUParticles2D = $Particles/GhostParticles
#endregion

#region Audio
@onready var land_sfx: SpatialAudioQueue = $Audio/LandSFX
@onready var switch_sfx: SpatialAudioQueue = $Audio/SwitchSFX
@onready var ghost_sfx: AudioStreamPlayer2D = $Audio/GhostSFX
@onready var jump_sfx: SpatialAudioQueue = $Audio/JumpSFX
@onready var hurt_sfx: SpatialAudioQueue = $Audio/HurtSFX
@onready var return_sfx: SpatialAudioQueue = $Audio/ReturnSFX
#endregion

func _ready() -> void:
	health = max_health
	player = get_node(player_path)
	partner_hitbox.get_node("CollisionShape2D").disabled = true
	
	ghost_particles.emitting = false
	ghost_sfx.bus = "Ghost"
	
	partner_hitbox.damage = damage
	
	if partner_condition and actor_to_track:
		setup_condition_connections()

func _set_state(new_state: int) -> void:
	if state != new_state:
		state = new_state
		emit_signal("state_changed", state)

func setup_condition_connections() -> void:
	if partner_condition is JumpCountCondition:
		actor_to_track.jumped.connect(partner_condition.on_character_jump)
	
	elif partner_condition is CoinCountCondition:
		actor_to_track.coin_collected.connect(partner_condition.on_coin_collected)
	
	elif partner_condition is TakeDamageCondition:
		var take_damage_condition = partner_condition as TakeDamageCondition
		take_damage_condition.actor_to_track = actor_to_track
		# Check if already connected before connecting
		if not actor_to_track.got_damaged.is_connected(take_damage_condition.on_character_hit):
			actor_to_track.got_damaged.connect(take_damage_condition.on_character_hit)

func movement(delta) -> void:
	if player:
		if state == PartnerState.FOLLOWING:
			follow_player(delta)
		elif state == PartnerState.HOMING:
			homing(delta)
		else:
			velocity = Vector2(0, 0)

func turning(direction) -> void:
	if direction != 0:
		partner_sprite.flip_h = direction < 0

func follow_player(delta) -> void:
	var distance_to_player = player.global_position.distance_to(global_position)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collision_mask = 3
	query.exclude = [self]
	
	# Only check for being stuck if we're on the ground
	var is_stuck = is_on_floor() and is_position_stuck(global_position, query, space_state)
	
	# Handle teleportation for being too far or stuck
	if distance_to_player > max_distance or is_stuck:
		var target_position = player.global_position + Vector2(randf_range(-follow_distance, follow_distance), 0)
		var safe_position = find_safe_position(target_position, query, space_state)
		global_position = safe_position
		velocity = Vector2.ZERO
		return
	
	# Normal following behavior
	var distance_x = player.global_position.x - global_position.x
	var abs_distance_x = abs(distance_x)
	var direction = 0
	
	if abs_distance_x > follow_distance:
		# Partner is too far; move closer
		direction = sign(distance_x)
		turning(direction)
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		# Within follow distance; slow down
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	# Vertical movement
	var vertical_distance = player.global_position.y - global_position.y
	if vertical_distance < -20 and is_on_floor():
		jump()

func jump() -> void:
	super.jump()
	jump_sfx.play_sound(position, 'SFX')

# If partner stuck in terrain
func is_position_stuck(pos: Vector2, query: PhysicsPointQueryParameters2D, space_state: PhysicsDirectSpaceState2D) -> bool:
	query.position = pos
	var results = space_state.intersect_point(query)
	
	for result in results:
		var collider = result['collider']
		if collider is TileMap or collider is StaticBody2D:
			return true
	return false

func find_safe_position(target_position: Vector2, query: PhysicsPointQueryParameters2D, space_state: PhysicsDirectSpaceState2D) -> Vector2:
	query.position = target_position
	if not is_position_stuck(target_position, query, space_state):
		return target_position
	
	# Try small random adjustments to find a nearby safe spot
	for i in range(10):
		var adjusted_position = target_position + Vector2(randi_range(-10, 10), randi_range(-10, 10))
		if not is_position_stuck(adjusted_position, query, space_state):
			return adjusted_position
	
	# If no safe spot found, try to place above the player
	var above_player = player.global_position + Vector2(0, -32)
	if not is_position_stuck(above_player, query, space_state):
		return above_player
	
	# Fallback to the player's exact position if all else fails
	return player.global_position

func homing(delta: float) -> void:
	if player != null:
		var direction_vector = player.global_position - global_position
		var distance = direction_vector.length()
		var direction = direction_vector.normalized()
		
		velocity = direction * homing_speed

		turning(direction.x)

func should_apply_gravity() -> bool:
	return state != PartnerState.HOMING

func landed() -> void:
	land_particles.emitting = true
	land_sfx.play_sound(position, "SFX")

func animations() -> void:
	var anim: String

func reset() -> void:
	_set_state(PartnerState.FOLLOWING)
	partner_condition.reset()
	homing_triggered = false
	partner_hitbox.get_node("CollisionShape2D").call_deferred("set_disabled", true)
	ghost_particles.emitting = false
	partner_sprite.modulate = Color(1, 1, 1)
	health = max_health
	emit_signal("health_changed", health) 
	velocity = Vector2.ZERO
	pause_timer.stop()
	set_collision_mask_value(3, true)
	if ghost_sfx.playing:
		ghost_sfx.stop()

func take_damage(damage_taken: int) -> void:
	# Turns back progress whenever the enemy is in a condition where damage doesnt matter
	if state == PartnerState.FOLLOWING and partner_condition:
		if partner_condition is TakeDamageCondition and actor_to_track == self:
			hurt_sfx.play_sound(position, 'SFX')
			partner_condition.adjust_progress(-1)
	
	if state == PartnerState.HOMING:
		hurt_sfx.play_sound(position, 'SFX')
		super.take_damage(damage_taken)
		
		if health == 0:
			return_sfx.play_sound(position, "SFX")
			reset()

func _physics_process(delta: float) -> void:
	if state == PartnerState.FOLLOWING and partner_condition:
		# Visual feedback
		var progress = partner_condition.get_progress()
		partner_sprite.modulate = Color(1, 1 - progress, 1 - progress)
		
		if partner_condition and partner_condition.is_met(delta):
			_set_state(PartnerState.PAUSED)
			switch_sfx.play_sound(position, "SFX")
			pause_timer.start(pause_duration)
			
	# Call the base class method
	super._physics_process(delta)

func on_health_collected(health_amount: int) -> void:
	AudioManager.play_sound("HealthSFX", position, "SFX", true)
	# Only call super if we're not in FOLLOWING state with TakeDamageCondition
	if not (state == PartnerState.FOLLOWING and partner_condition is TakeDamageCondition):
		super.on_health_collected(health_amount)

	if state == PartnerState.FOLLOWING and partner_condition:
		if partner_condition is TakeDamageCondition:
			partner_condition.adjust_progress(health_amount)
		else:
			partner_condition.adjust_progress(-health_amount)
	
	if state == PartnerState.HOMING:
		health -= health_amount
		health = clamp(health, 0, max_health)
		
		# If partner dies while homing, reset to normal
		if health == 0:
			reset()

# Timer for delay before turning evil
func _on_timer_timeout() -> void:
	if health > 0 and not homing_triggered:
		ghost_particles.emitting = true
		set_collision_mask_value(3, false)
		_set_state(PartnerState.HOMING)
		partner_hitbox.get_node("CollisionShape2D").disabled = false
		homing_triggered = true
		ghost_sfx.play()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		take_damage(hitbox.damage)

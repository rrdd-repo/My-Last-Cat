class_name Actor
extends CharacterBody2D

#region Health
@export var max_health: int = 5
var health: int
#endregion

#region Physics
@export_group("Physics Variables")
@export var speed: float = 500.0
@export var jump_velocity: float = -350.0
@export var acceleration: float = 2000.0
@export var deceleration: float = 1500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var ismoving: bool = true
#endregion

#region Jumping
@export_group("Jump Variables")
var fall_multiplier: float = 1.0
@export var jump_buffer_time: float = 0.2
@export var coyote_time: float = 0.2
var jump_buffer_counter: float = 0.0
var coyote_time_counter: float = 0.0
var was_on_floor: bool = true
#endregion

#region Conditions
signal got_damaged(damaged_actor: Actor)
signal jumped
signal coin_collected
signal health_changed(new_health: int)
#endregion

#region Death
signal is_dead
#endregion

func _ready() -> void:
	health = max_health

func _physics_process(delta):
	# Gravity
	if should_apply_gravity():
		velocity.y += gravity * delta * fall_multiplier

	# Coyote time
	if is_on_floor():
		coyote_time_counter = coyote_time
		fall_multiplier = 1.0
	else:
		coyote_time_counter = max(coyote_time_counter - delta, 0.0)

	# Jump buffering
	if should_jump(delta):
		jump()

	# Movement and Animations
	movement(delta)
	animations()

	move_and_slide()
	
	if is_on_floor() and not was_on_floor:
		landed()
		
	was_on_floor = is_on_floor()

func should_jump(delta):
	return false

func jump():
	emit_signal("jumped")
	fall_multiplier = 1.0
	velocity.y = jump_velocity
	jump_buffer_counter = 0.0
	coyote_time_counter = 0.0

func movement(delta) -> void:
	pass

func animations() -> void:
	pass

func turning(direction) -> void:
	pass
	
func should_apply_gravity() -> bool:
	return true
	
func landed() -> void:
	pass

func reset() -> void:
	pass

func on_coin_collected() -> void:
	AudioManager.play_sound("CoinSFX", position, "SFX", false)
	emit_signal("coin_collected")
	
func on_health_collected(health_amount: int) -> void:
	AudioManager.play_sound("HealthSFX", position, "SFX", false)
	health += health_amount
	health = clamp(health, 0, max_health)
	
	emit_signal("health_changed", health)

func take_damage(damage_taken: int) -> void:
	health -= damage_taken
	health = clamp(health, 0, max_health)
	
	emit_signal("got_damaged", self)
	emit_signal("health_changed", health)
	
	if health == 0:
		emit_signal("is_dead")

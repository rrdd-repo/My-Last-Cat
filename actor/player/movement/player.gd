class_name Player
extends Actor

@onready var player_hitbox: Area2D = $Boxes/PlayerHitbox
var facing_direction: int = 1

#region Aesthetics
@onready var player_sprite: AnimatedSprite2D = $Animation/AnimatedSprite2D
@onready var dash_particles: CPUParticles2D = $Particles/DashParticles
@onready var land_particles: CPUParticles2D = $Particles/LandParticles
@onready var hit_particles: CPUParticles2D = $Particles/HitParticles
#endregion

#region Damage
var hitstop_duration: float = 0.025
var hitstop_factor: float = 0.05
#endregion

#region Dash
# Different values
@export var dash_speed_horizontal: float = 600.0
@export var dash_speed_vertical: float = 450.0
@export var dash_speed_diagonal: float = 530.0
var dash_velocity: Vector2 = Vector2.ZERO

@export var dash_duration: float = 0.15
var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
#endregion

#region Audio
@onready var swoosh_sfx_pool: AudioPool = $Audio/SwooshSFXPool
@onready var jump_sfx: AudioQueue = $Audio/JumpSFX
@onready var land_sfx: AudioQueue = $Audio/LandSFX
@onready var hurt_sfx: AudioQueue = $Audio/HurtSFX
@onready var explosion_sfx: AudioQueue = $Audio/ExplosionSFX
@onready var death_sfx: AudioQueue = $Audio/DeathSFX
#endregion

func _ready() -> void:
	super._ready()
	player_hitbox.get_node("CollisionShape2D").disabled = true

func should_jump(delta: float) -> bool:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time
	if jump_buffer_counter > 0:
		jump_buffer_counter = max(jump_buffer_counter - delta, 0.0)
		return is_on_floor() or coyote_time_counter > 0
	return false

func movement(delta: float) -> void:
	if is_dashing:
		# Skip gravity and regular movement during dash
		velocity = dash_velocity
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		var direction: float = Input.get_axis("move_left", "move_right")
		turning(direction)
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
		# Handle jumping
		if should_jump(delta):
			jump()
		
		# Dash mechanics
		if Input.is_action_just_pressed("dash") and can_dash and not is_on_floor():
			is_dashing = true
			can_dash = false
			dash_timer = dash_duration
			
			# Determine dash direction
			dash_direction = Vector2(
				Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
				Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			)
			
			# Default to facing direction if no input
			if dash_direction == Vector2.ZERO:
				dash_direction = Vector2(facing_direction, 0)
			set_dash_velocity()
			
			dash_particles.emitting = true
			swoosh_sfx_pool.play_random_sound("SFX")

func jump() -> void:
	jump_sfx.play_sound("SFX")
	super.jump()

func set_dash_velocity() -> void:
	# Normalize the direction without changing zero vectors
	var normalized_direction = dash_direction.normalized() if dash_direction.length() > 0 else dash_direction

	if abs(normalized_direction.x) == 1 and normalized_direction.y == 0:
		# Horizontal dash
		dash_velocity = normalized_direction * dash_speed_horizontal
	elif normalized_direction.x == 0 and abs(normalized_direction.y) == 1:
		# Vertical dash
		dash_velocity = normalized_direction * dash_speed_vertical
	else:
		# Diagonal dash
		dash_velocity = normalized_direction * dash_speed_diagonal

func should_apply_gravity() -> bool:
	return not is_dashing

func landed() -> void:
	land_particles.emitting = true
	land_sfx.play_sound("SFX")
	
func animations() -> void:
	var anim: String
	if is_on_floor():
		anim = "idle" if velocity.x == 0 else "run"
	else:
		anim = "jump"
		
	player_sprite.play(anim)

func turning(direction: float) -> void:
	if is_dashing:
		if dash_direction.x != 0:
			player_sprite.flip_h = dash_direction.x < 0
			facing_direction = int(sign(dash_direction.x))
	elif direction != 0:
		player_sprite.flip_h = direction < 0
		facing_direction = int(sign(direction))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_on_floor():
		can_dash = true

# This really doesnt need to be in the player script lol
func apply_hitstop(duration, timeScale) -> void:
	player_sprite.modulate = Color(1, 0.5, 0.5, 0.5)
	Engine.time_scale = timeScale
	await(get_tree().create_timer(duration).timeout)
	explosion_sfx.play_sound('SFX')
	player_sprite.modulate = Color(1, 1, 1, 1)
	Engine.time_scale = 1.0
	hit_particles.emitting = true
	
	player_hitbox.get_node("CollisionShape2D").disabled = false
	await(get_tree().create_timer(0.2).timeout)
	player_hitbox.get_node("CollisionShape2D").disabled = true

func on_health_collected(health_amount: int) -> void:
	super.on_health_collected(health_amount)
	health += health_amount
	health = clamp(health, 0, max_health)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		take_damage(hitbox.damage)
		hurt_sfx.play_sound('SFX')
		apply_hitstop(hitstop_duration, hitstop_factor)
		
		
func take_damage(damage: int) -> void:
	super.take_damage(damage)
	print(damage)
	
	if health == 0:
		death_sfx.play_sound('SFX')

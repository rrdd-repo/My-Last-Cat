class_name BasicEnemy
extends Actor

@export var move_range: float = 200.0
@export var move_speed: float = 100.0

var direction: int = 1
var start_position: Vector2

@export var is_floating: bool = false

@onready var enemy_sprite: Sprite2D = $Sprite2D
@onready var hurt_sfx: SpatialAudioQueue = $Audio/HurtSFX

func _ready() -> void:
	super._ready()
	start_position = position

func _physics_process(delta: float):
	# Apply gravity only if the enemy is not floating
	if should_apply_gravity():
		velocity.y += gravity * delta * fall_multiplier

	# Handle direction change upon hitting a wall
	if is_on_wall():
		reverse_direction()

	# Move left and right within the defined range
	movement(delta)
	move_and_slide()

func should_apply_gravity() -> bool:
	return !is_floating

func movement(delta: float) -> void:
	# Check if the enemy has moved past the range limit
	if abs(position.x - start_position.x) >= move_range:
		# Reverse direction if at the edge of move range
		reverse_direction()

	# Set horizontal velocity based on direction and move_speed
	velocity.x = move_speed * direction

func reverse_direction() -> void:
	# Reverse direction and flip the sprite
	direction *= -1
	enemy_sprite.flip_h = direction < 0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		take_damage(hitbox.damage)

func take_damage(damage_taken: int) -> void:
	hurt_sfx.play_sound(position, 'SFX')
	super.take_damage(damage_taken)
	if health == 0:
		await get_tree().create_timer(0.1).timeout
		queue_free()

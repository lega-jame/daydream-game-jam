extends CharacterBody2D

const SPEED = 50
const JUMP_VELOCITY = -180
const GRAVITY = 500.0

@export var max_health := 100
var current_health := max_health

var is_attacking = false

# Nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $hitbox
@onready var shape_idle: CollisionShape2D = $idle
@onready var shape_attack: CollisionShape2D = $sword
@onready var shape_running: CollisionShape2D = $running
@onready var health_bar: TextureProgressBar = $Camera2D/TextureProgressBar

func _ready():
	health_bar.max_value = max_health
	update_health_bar()
	animated_sprite.play("Linton S3")

	# Connect signals (if not already connected in editor)
	animated_sprite.animation_finished.connect(self._on_animation_finished)
	animated_sprite.animation_changed.connect(self._on_animation_changed)

# -------- Movement --------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if is_on_floor():
		if direction == 0 and not is_attacking:
			animated_sprite.play("Linton S3")
		elif direction != 0 and not is_attacking:
			animated_sprite.play("walking")
	else:
		if not is_attacking:
			animated_sprite.play("jumping")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# -------- Attack --------
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

func attack():
	is_attacking = true
	animated_sprite.play("swinging")

	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(10)

# -------- Animation Callbacks --------
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "swinging":
		is_attacking = false
func _on_animated_sprite_2d_animation_changed():
	shape_idle.disabled = true
	shape_attack.disabled = true
	shape_running.disabled = true

	match animated_sprite.animation:
		"Linton S3": shape_idle.disabled = false
		"walking": shape_running.disabled = false
		"swinging": shape_attack.disabled = false

# -------- Health System --------
func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	update_health_bar()
	animated_sprite.play("hurted")

	if current_health <= 0:
		die()

func update_health_bar() -> void:
	health_bar.value = current_health

func die() -> void:
	queue_free()

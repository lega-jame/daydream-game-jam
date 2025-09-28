extends CharacterBody2D

# Example: For Godot 4.x (GDScript)
@export var max_health := 100
var current_health := max_health

# Drag in the health bar from the scene or use get_node()
@onready var health_bar := $Camera2D/TextureProgressBar

func _ready():
	update_health_bar()

func take_damage(amount):
	current_health = max(current_health - amount, 0)
	update_health_bar()
	animated_sprite.play("hurted")
	if current_health <= 0:
		die()

func update_health_bar():
	health_bar.value = current_health

func die():
	queue_free()

const SPEED = 50
const JUMP_VELOCITY = -180

@onready var animated_sprite= $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left","move_right")
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Linton S3")
		else:
			animated_sprite.play("walking")
	else:
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

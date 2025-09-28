extends Node2D

@export var max_health := 100
var current_health := max_health

@onready var health_bar: ProgressBar = $Control/ProgressBar

func _ready():
	update_health_bar()

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	update_health_bar()
	if current_health <= 0:
		die()

func update_health_bar():
	health_bar.value = current_health

func die():
	queue_free()

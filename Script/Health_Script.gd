class_name Health_Node
extends Node

@export var max_health : float
var health : float

signal health_changed(health : float)
signal damage_taken(value : float)
signal healed(value : float)
signal died()

func _ready() -> void:
	health = max_health

func take_damage(value : float):
	health = clamp(health - value, 0 , max_health)
	emit_signal("damage_taken", value)
	emit_signal("health_changed", health)
	if health > 0:
		print("taken ", value,  " damage ", health, " remaining.")
	elif health <=0:
		emit_signal("died")
		print("die")

func heal(value : float):
	health = clamp(health + value, 0 , max_health)
	emit_signal("healed", value)
	emit_signal("health_changed", health)
	print("heal")

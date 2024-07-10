class_name Weapon extends Node3D

@export var automatic = false
@export var fire_rate = 1.0

# Flag used for switching off non-auto weapons
var should_fire = true

func use() -> void:
	print("not implemented")

# Represents a holdable item.
class_name ItemResource extends Resource

@export var instance: PackedScene
@export var cost: int
@export_range(0, 9) var key: int
@export var name: String

func _init(p_name = "", p_instance = null, p_cost = 0, p_key = 0):
	name = p_name
	instance = p_instance
	cost = p_cost
	key = p_key

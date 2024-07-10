# Represents a holdable item.
class_name ItemResource extends BuyableResource

@export var instance: PackedScene
@export_range(0, 9) var key: int

func _init(p_name = "", p_instance = null, p_cost = 0, p_key = 0):
	super(p_name, p_cost)
	instance = p_instance
	key = p_key

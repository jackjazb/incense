extends Node3D

@export var money: PackedScene

## The gap between spawning money instances.
@export var interval: float

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new();
	timer.autostart = true
	timer.wait_time = interval
	timer.timeout.connect(spawn_money)
	add_child(timer)

func spawn_money():
	var instance = money.instantiate()
	add_child(instance)

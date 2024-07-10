class_name Money extends Node3D

@export var spin_speed = 1.2
@export var float_speed = 0.004
var amount = 1

var created_at

func _ready():
	created_at = Time.get_ticks_msec()
	$Area3D.body_entered.connect(on_body_entered)

func _process(delta):
	var alive_for = Time.get_ticks_msec() - created_at
	rotate_y(spin_speed * delta)
	position.y = 0.5 + (sin(float_speed * alive_for) / 2)

func on_body_entered(body: Node3D):
	if body is Player:
		body.add_money(amount)
		queue_free()

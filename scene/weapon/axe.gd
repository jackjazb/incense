extends Node3D

const swing_range = 2.0
const damage = 5.0

func _process(_delta):
	if not is_multiplayer_authority(): return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$AnimationPlayer.play("swing")
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * swing_range, 2)
		var collision = space.intersect_ray(query)
		if collision:
			var collider = collision.collider
			if collider is Player:
				collider.do_damage.rpc_id(collider.get_multiplayer_authority(), damage)

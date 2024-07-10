extends Weapon

const swing_range = 2.0
const damage = 5.0

func use():
	if not should_fire:
		return
	$AnimationPlayer.play("swing")
	var space = super.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * swing_range)
	var collision = space.intersect_ray(query)

	if collision:
		var collider = collision.collider
		if collider is Player:
			collider.do_damage.rpc_id(collider.get_multiplayer_authority(), damage)
		if (collision.collider as CollisionObject3D).get_collision_layer_value(4):
			collision.collider.queue_free()
	should_fire = false


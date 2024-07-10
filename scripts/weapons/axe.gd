extends Weapon

const swing_range := 2.0
const damage := 5.0
var should_swing := true

func _process(_delta):
	if not super.should_process(): return

	if Input.is_action_just_released("click"):
		should_swing = true

	if Input.is_action_just_pressed("click") and should_swing:
		if $AnimationPlayer.is_playing():
			return
		$AnimationPlayer.play("swing")
		var space = super.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * swing_range)
		var collision = space.intersect_ray(query)

		if collision:
			var collider = collision.collider
			if collider is Player && collider.get_multiplayer_authority() != multiplayer.get_unique_id():
				collider.do_damage.rpc_id(collider.get_multiplayer_authority(), damage)
			if (collision.collider as CollisionObject3D).get_collision_layer_value(4):
				collision.collider.queue_free()
		should_swing = false


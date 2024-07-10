extends Weapon

const fire_rate := 14.0
const ray_length := 200.0
const damage := 5.0

@onready var audio_player = $AudioStreamPlayer3D

var shot_time := 1.0 / fire_rate
var since_last_shot := 0.0


func _process(delta):
	if not super.should_process(): return
	since_last_shot += delta

	if Input.is_action_pressed("click"):
		if since_last_shot > shot_time:
			print("fired")
			audio_player.play()
			var space = super.get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(global_position,global_position - global_transform.basis.z * ray_length)
			var collision = space.intersect_ray(query)
			print(collision)
			if collision:
				var collider = collision.collider
				if collider is Player && collider.get_multiplayer_authority() != multiplayer.get_unique_id():
					collider.do_damage.rpc_id(collider.get_multiplayer_authority(), damage)
			since_last_shot = 0.0

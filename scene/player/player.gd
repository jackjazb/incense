class_name Player extends CharacterBody3D

const speed := 20.0
const acceleration := 15
const sensitivity := 0.4
const jump_speed := 10.0
const gravity := 30.0
const max_health := 10.0

@onready var camera = $Camera3D

# Multiplayer vars
var peer_id: int

# Game vars
var health := max_health
var money := 0

var team: World.Team
var spawn_pos: Vector3

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

var rot_x := 0.0
var rot_y := 0.0

func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		# Obtain and clamp x rotation.
		rot_x -= deg_to_rad(event.relative.y) * sensitivity
		rot_x = clamp(rot_x, -PI/2, PI/2)
		camera.transform.basis = Basis()
		camera.rotate_x(rot_x)

		# Obtain y rotation.
		rot_y -= deg_to_rad(event.relative.x) * sensitivity
		transform.basis = Basis()
		rotate_y(rot_y)

	if event is InputEventKey:
		if event.keycode == KEY_Q:
			get_tree().quit()
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	# Apply upwards force if we've jumped.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	# Apply gravity if we're in the air.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Apply horizontal movement.
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	var dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerpf(velocity.x, dir.x * speed, acceleration * delta)
	velocity.z = lerpf(velocity.z, dir.z * speed, acceleration * delta)

	Debug.show_value("peer_id", get_multiplayer_authority())
	Debug.show_value("is_server", multiplayer.is_server())
	Debug.show_value("velocity", "%.2v (%.2f m/s)" % [velocity, velocity.length()])
	Debug.show_value("position","%.2v" % position)
	Debug.show_value("health","%.2f" % health)
	Debug.show_value("money","%.2d" % money)
	Debug.show_value("team", "%s (%s)" %[World.get_team_name(team), team])

	move_and_slide()

func respawn_if_bed():
	# Want to check if the player team's bed exists. For now, just respawn.
	self.position = spawn_pos
	self.health = max_health

func add_money(amount: int):
	money += amount

@rpc("any_peer")
func do_damage(amount: float):
	print("player %s hit for %d" % [peer_id, amount])
	health -= amount
	if health <= 0:
		respawn_if_bed()

@rpc("call_local", "any_peer")
func set_team(p_team: World.Team):
	team = p_team

	# Update the player's base
	var bases = get_tree().get_nodes_in_group("base")
	for base in bases:
		if base.get_meta("team") == team:
			spawn_pos = base.position
			translate(spawn_pos)


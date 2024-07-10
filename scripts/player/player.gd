class_name Player extends CharacterBody3D

const speed := 18.0
const acceleration := 15
const sensitivity := 0.3
const jump_speed := 10.0
const gravity := 30.0
const max_health := 100.0

# If the player's y position is below this level, they are killed.
const kill_y := -50.0

@onready var camera = $Camera3D
@onready var hand = $Camera3D/Hand

@export var pause_menu: Container

var paused = false

# Game vars
var health := max_health
var money := 0

var team: World.Team
var spawn_pos: Vector3

var spawn: Transform3D

# Track mouse inputs
var rot = Vector2.ZERO

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	pause_menu.hide()
	if not is_multiplayer_authority(): return

	# Ensures weapons have the correct authority.
	hand.set_multiplayer_authority(name.to_int())

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority() or paused: return

	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		camera.transform.basis = Basis()
		transform.basis = Basis()
		# Obtain and clamp x rotation.
		rot.x -= deg_to_rad(event.relative.y) * sensitivity
		rot.x = clamp(rot.x, -PI/2, PI/2)
		camera.rotate_x(rot.x)

		# Obtain y rotation.
		rot.y -= deg_to_rad(event.relative.x) * sensitivity
		rotate_y(rot.y)

func toggle_paused():
	paused = !paused
	Global.overlay_active = paused
	if paused:
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	Debug.show_value("peer_id", multiplayer.get_unique_id())
	Debug.show_value("is_server", multiplayer.is_server())
	Debug.show_value("velocity", "%.2v (%.2f m/s)" % [velocity, velocity.length()])
	Debug.show_value("position","%.2v" % position)
	Debug.show_value("rotation","%.2v" % rotation)
	Debug.show_value("camera rotation","%.2v" % camera.rotation)
	Debug.show_value("spawn at","%.2v" % spawn.origin)
	Debug.show_value("on floor", "%s" % [is_on_floor()])

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	if Input.is_action_just_pressed("ui_cancel"):
		toggle_paused()

	if position.y <= kill_y:
		health = 0.0

	if health <= 0:
		print("died!")
		respawn()

	if paused: return
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
	move_and_slide()

func is_bed_present():
	var beds = get_tree().get_nodes_in_group("bed")
	for bed in beds:
		var bed_team = bed.get_meta("team")
		if bed_team == team:
			return true
	return false

func reset_camera():
	camera.transform.basis = Basis()
	transform.basis = Basis()
	rot = Vector2.ZERO

# Respawns the player in their base if the team's bed is still present.
func respawn():
	if !is_bed_present():
		print("dead!")
		return

	transform = spawn
	velocity = Vector3.ZERO
	health = max_health
	money = 0

	reset_camera()

func add_money(amount: int):
	money += amount

@rpc("any_peer")
func do_damage(amount: float):
	print("player %s hit for %d" % [multiplayer.get_unique_id(), amount])
	health -= amount

@rpc("call_local", "any_peer")
func set_team(p_team: World.Team):
	team = p_team

	# Update the player's base
	var bases = get_tree().get_nodes_in_group("base")
	for base in bases:
		if base.team == team:
			# Sets spawn origin to the team's base and rotates to look at the z
			spawn.origin = Vector3(base.position.x, 1.0, base.position.z)
			spawn.basis = Basis.from_euler(Vector3(0.0, atan2(spawn.origin.x, spawn.origin.z), 0.0))
			respawn()



func _on_resume_pressed():
	toggle_paused()

func _on_quit_pressed():
	get_tree().quit()

class_name World extends Node3D

const PORT = 5000

enum Team{
	RED,
	BLUE,
	GREEN,
	ORANGE
}

static func get_team_name(team: World.Team):
	return World.Team.keys()[team]

# Set this based on the game type chosen.
var available_teams := [Team.RED, Team.BLUE]

# Maps team name to a list of players.
var teams := {}

@export var join_button: Button
@export var host_button: Button
@export var menu: Control
@export var player: PackedScene = load("res://scenes/player/player.tscn")

var enet_peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# For debug purposes
	#host()

	host_button.pressed.connect(host)
	join_button.pressed.connect(join)

func host():
	menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

	# Initialise empty teams.
	for team in available_teams:
		teams[team] = []

	peer_connected(multiplayer.get_unique_id())

func join():
	menu.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

# This runs on the server only.
func peer_connected(peer_id):
	assert(teams.keys().size() != 0, "teams must be initialised")

	var player_instance: Player = player.instantiate()
	player_instance.name = str(peer_id)
	# Determine which team to add the player to.
	var emptiest_team: Team = teams.keys()[0]
	for team in teams.keys():
		if emptiest_team == null:
			emptiest_team = team

		if (teams[team] as Array).size() < teams[emptiest_team].size():
			emptiest_team = team
	(teams[emptiest_team] as Array).append(player_instance)
	add_child(player_instance)
	player_instance.set_team.rpc(emptiest_team)


func peer_disconnected(peer_id):
	var player_instance = get_node_or_null(str(peer_id))
	if player_instance:
		player_instance.queue_free()

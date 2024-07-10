extends Node3D

@export var team: World.Team
@export var bed: Node3D

func _ready():
	$TeamLabel.text = World.get_team_name(team) + " base"
	bed.set_meta("team", team)

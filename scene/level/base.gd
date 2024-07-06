extends Node3D

func _ready():
	$TeamLabel.text = World.get_team_name(get_meta("team")) + " base"

class_name Weapon extends Node3D

func should_process():
	return is_multiplayer_authority() && !Global.overlay_active && visible

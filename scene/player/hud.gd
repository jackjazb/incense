extends CanvasLayer

@export var player: Player
@export var health: ProgressBar
@export var money: Label
@export var team: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority(): queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	health.value = player.health / player.max_health
	money.text = str(player.money)
	team.text = World.get_team_name(player.team)

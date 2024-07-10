extends Node3D

@export var interactable: Interactable

@export_category("UI")
@export var ui_root: CanvasLayer
@export var close_button: Button

@export var ordnance_container: Container
@export var boosters_container: Container
@export var defences_container: Container

@export var buy_button: PackedScene = preload("res://scenes/ui/buy_button.tscn")

@export_category("Buyable Items")
@export var ordnance: Array[BuyableResource]
@export var boosters: Array[BuyableResource]
@export var defences: Array[BuyableResource]

var ui_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	interactable.used.connect(_on_used)
	close_button.pressed.connect(_on_close)
	populate_container(ordnance, ordnance_container)
	populate_container(defences, boosters_container)
	populate_container(defences, defences_container)
	ui_root.hide()

func populate_container(items: Array[BuyableResource], container: Container):
	for item in items:
		var btn = buy_button.instantiate() as Button
		var symbol = ""
		match item.currency:
			BuyableResource.Currency.Cash:
				symbol = Global.CASH_SYMBOL
			BuyableResource.Currency.Diamonds:
				symbol = Global.DIAMOND_SYMBOL
		btn.text = "%s (%d%s)" % [item.name, item.cost, symbol]
		container.add_child(btn)

func _on_close():
	ui_open = false
	ui_root.hide()
	Global.overlay_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_used():
	if not ui_open:
		ui_open = true
		ui_root.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Global.overlay_active = true


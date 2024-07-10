## Allows a player to maintain an inventory of holdable items and interact with the Interactable areas.
class_name Hand extends Node3D

# Hold the Axe by default
var axe: ItemResource = preload("res://resources/weapons/axe.tres")
var handgun: ItemResource = preload("res://resources/weapons/handgun.tres")

@export var use_indicator: Label

@onready var raycast: RayCast3D = $RayCast3D

# Maps 0-9 to a list of items associated with that key.
var inventory := {}
var current_item: Node3D
var current_key = 1
var current_index = 0

# Flag to prevent
var can_switch = true

func _ready():
	add_item(axe)
	add_item(handgun)
	# Swap to the axe by default.
	current_key = axe.key
	next_item(current_key)

	var use_key = InputMap.action_get_events("use")[0].as_text_physical_keycode()
	use_indicator.text = "[%s] to use" % use_key

## Adds an item to the player's inventory and switches to it.
func add_item(item: ItemResource):
	if !inventory.get(item.key):
		inventory[item.key] = []
	var item_instance: Node3D = item.instance.instantiate()
	item_instance.visible = false
	(inventory[item.key] as Array).append(item_instance)
	add_child(item_instance)

## Swaps to the given key. If the key is already picked, cycles through the slot's contents.
func next_item(key: int):
	if inventory.get(key) == null:
		return
	inventory.get(current_key)[current_index].visible = false

	if key == current_key:
		current_index = (current_index + 1) % ((inventory.get(current_key) as Array).size())
	else:
		current_index = 0
		current_key = key
	current_item = inventory.get(current_key)[current_index]
	current_item.visible = true

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	# Use keys 0-9 for swapping weapon slots.
	if event is InputEventKey:
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			if event.is_released():
				can_switch = true
			if not can_switch:
				return

			var num = event.keycode - KEY_0
			next_item(num)
			can_switch = false

func _process(_delta):
	if not is_multiplayer_authority():
		return
	# Handle ray collisions with Interactable components.
	var collider = raycast.get_collider()
	if collider and collider is Interactable:
		use_indicator.show()
		var interactable := collider as Interactable
		interactable.hovered = true

		if Input.is_action_just_pressed("use"):
			interactable.use()
	else:
		use_indicator.hide()
	if Input.is_action_just_pressed("click"):
		current_item.use()
	if Input.is_action_just_released("click"):
		current_item.should_fire = true


extends Label

var props := {}

func _ready():
	if not is_multiplayer_authority(): queue_free()
	position = Vector2(5, 5);
	hide()

func _process(_delta):
	text = ""
	for k in props.keys():
		if k:
			text += k + ": " + str(props[k]) + "\n"

func show_value(key: String, value: Variant):
	props[key] = value

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		self.visible = ! self.visible

extends Label

var props := {}

func _ready():
	if not is_multiplayer_authority(): queue_free()
	add_theme_font_override("font", load("res://cascadia_code.tres"))
	add_theme_font_size_override("font_size", 12)
	position = Vector2(5, 5);

func _process(_delta):
	text = ""
	for k in props.keys():
		text += k + ": " + str(props[k]) + "\n"

func show_value(key: String, value: Variant):
	props[key] = value

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		self.visible = ! self.visible

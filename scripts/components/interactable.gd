## Add to Area3D to make them interactable.
## Should be on the "interactable" collision layer.
class_name Interactable extends Area3D

signal used

@export var object_mesh: MeshInstance3D
var hover_shader: Shader = preload("./interactable.gdshader")

var hovered = false

var hover_mat: ShaderMaterial
var default_mat: Material

func _ready():
	default_mat = object_mesh.material_override

	hover_mat = ShaderMaterial.new()
	hover_mat.shader = hover_shader

	# For some reason, hover_mat must be the first pass.
	hover_mat.next_pass = default_mat

func _process(_delta):
	object_mesh.material_override = hover_mat if hovered else default_mat
	hovered = false

func use():
	used.emit()

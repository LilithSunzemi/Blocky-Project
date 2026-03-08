extends MeshInstance3D

@export var model: MeshInstance3D
@export var area: Area3D
var highlight_mat: StandardMaterial3D = \
	preload("res://materials/highlight.tres")
var materials: Array[StandardMaterial3D]

func _ready():
	if model == null or area == null:
		for child in get_children():
			if model == null and child is MeshInstance3D:
				model = child
			if area == null and child is Area3D:
				area = child
	
	for i in model.get_surface_override_material_count():
		materials.append(model.get_surface_override_material(i))
	area.mouse_entered.connect(toggle_highlight.bind(true))
	area.mouse_exited.connect(toggle_highlight.bind(false))

func toggle_highlight(on: bool):
	for i in materials.size():
		model.set_surface_override_material(i, highlight_mat if on else materials[i])

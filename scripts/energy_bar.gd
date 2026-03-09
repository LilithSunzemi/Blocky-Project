extends ProgressBar

@export var player_path: NodePath

@onready var player: CharacterBody3D = get_node(player_path)


func _ready() -> void:
	set_max(player.max_energy) 
	set_value(player.current_energy)
	player.energy_changed.connect(_on_energy_changed)


func _on_energy_changed(new_energy: float, new_max: float) -> void:
	set_max(new_max)
	set_value(new_energy)
	_update_bar_color(new_energy / new_max)


func _update_bar_color(fill_ratio: float) -> void:
	var style = get_theme_stylebox("fill", "ProgressBar").duplicate()
	if fill_ratio > 0.5:
		style.bg_color = Color.YELLOW
	elif fill_ratio > 0.25:
		style.bg_color = Color.ORANGE
	else:
		style.bg_color = Color.ORANGE_RED
	add_theme_stylebox_override("fill", style)

extends ProgressBar

@export var player_path: NodePath

@onready var player: CharacterBody3D = get_node(player_path)


func _ready() -> void:
	set_max(player.max_health) 
	set_value(player.health)
	player.health_changed.connect(_on_health_changed)
	var style = get_theme_stylebox("fill", "ProgressBar").duplicate()
	style.bg_color = Color.RED
	add_theme_stylebox_override("fill", style)


func _on_health_changed(new_health: float, new_max: float) -> void:
	set_max(new_max)
	set_value(new_health)

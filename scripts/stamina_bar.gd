extends ProgressBar

@export var player_path: NodePath

@onready var player: CharacterBody3D = get_node(player_path)


func _ready() -> void:
	set_max(player.max_stamina) 
	set_value(player.stamina)
	player.stamina_changed.connect(_on_stamina_changed)
	var style = get_theme_stylebox("fill", "ProgressBar").duplicate()
	style.bg_color = Color.GREEN_YELLOW
	add_theme_stylebox_override("fill", style)


func _on_stamina_changed(new_stamina: float, new_max: float) -> void:
	set_max(new_max)
	set_value(new_stamina)

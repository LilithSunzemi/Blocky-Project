extends VBoxContainer

const WORLD = preload("uid://bu5sxj8v246m5")


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)



func _on_quit_button_pressed() -> void:
	get_tree().quit()

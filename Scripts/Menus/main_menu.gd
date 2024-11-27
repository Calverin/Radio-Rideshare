extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/level_selector.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/settings.tscn")


func _on_exit_button_pressed():
	get_tree().quit()

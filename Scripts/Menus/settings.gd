extends Control

func _process(delta):
	material.set("shader_parameter/aberration", lerpf(material.get("shader_parameter/aberration"), 0, delta * 2))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

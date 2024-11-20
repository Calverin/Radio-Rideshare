extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/level_selector.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/settings.tscn")


func _on_exit_button_pressed():
	get_tree().quit()

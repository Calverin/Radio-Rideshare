extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenuSound.play(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/root.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")


func _on_exit_button_pressed():
	get_tree().quit()

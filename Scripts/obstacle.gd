extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true;

func body_entered(body):
	if body is CharacterBody3D:
		$Crash.play()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

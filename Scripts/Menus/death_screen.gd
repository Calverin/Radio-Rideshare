extends ColorRect

var transition: int = 0
var dimming = false

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.reset_scores()
	UI.score = 0


func _process(delta: float) -> void:
	if transition == 0:
		material.set("shader_parameter/warp_amount", lerpf(material.get("shader_parameter/warp_amount"), 1, delta * 8))
		material.set("shader_parameter/aberration", lerpf(material.get("shader_parameter/aberration"), 0, delta * 2))
		material.set("shader_parameter/vignette_intensity", lerpf(material.get("shader_parameter/vignette_intensity"), 1, delta * 4))
		material.set("shader_parameter/vignette_opacity", lerpf(material.get("shader_parameter/vignette_opacity"), 0.2, delta * 2))
	else:
		transition += 1
		material.set("shader_parameter/aberration", lerpf(material.get("shader_parameter/aberration"), 1, delta * 2))
		if dimming:
			material.set("shader_parameter/warp_amount", lerpf(material.get("shader_parameter/warp_amount"), 20, delta * 8))
			material.set("shader_parameter/vignette_intensity", lerpf(material.get("shader_parameter/vignette_intensity"), 100, delta * 4))
			material.set("shader_parameter/vignette_opacity", lerpf(material.get("shader_parameter/vignette_opacity"), 1, delta * 2))


func _on_exit_button_pressed():
	transition = 1
	dimming = true
	await get_tree().create_timer(0.75, false).timeout
	get_tree().quit()


func _on_main_menu_pressed():
	transition = 1
	await get_tree().create_timer(0.25, false).timeout
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

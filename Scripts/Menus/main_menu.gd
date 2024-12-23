extends Control

var transition: int = 0
var dimming = false

func _ready() -> void:
	material.set("shader_parameter/warp_amount", 20)
	material.set("shader_parameter/aberration", 1)
	material.set("shader_parameter/vignette_intensity", 100)
	material.set("shader_parameter/vignette_opacity", 1)
	
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

func _on_start_button_pressed():
	transition = 1
	await get_tree().create_timer(0.25, false).timeout
	material.set("shader_parameter/warp_amount", 1)
	material.set("shader_parameter/vignette_intensity", 1)
	material.set("shader_parameter/vignette_opacity", 0.2)
	get_tree().change_scene_to_file("res://Scenes/Menus/level_selector.tscn")


func _on_options_button_pressed():
	transition = 1
	await get_tree().create_timer(0.25, false).timeout
	get_tree().change_scene_to_file("res://Scenes/Menus/settings.tscn")


func _on_exit_button_pressed():
	transition = 1
	dimming = true
	$ExitSound.play()
	await get_tree().create_timer(1.5, false).timeout
	get_tree().quit()

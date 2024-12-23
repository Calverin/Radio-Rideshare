extends Area3D

var speed: int
var lanes: int
var current_lane: int

var dead: bool = false

var drifting: bool = false
var drift_time: int = 0
var drift_on: bool = false
var drift_score: int = 0
var drift_direction: float = 0
var turn_offset: float = 0

func _ready():
	speed = 50
	lanes = LevelLoader.current_level.lanes
	current_lane = ceil(float(lanes) / 2)
	position.x = current_lane * 10

func _process(delta: float):
	# Honking
	if (Input.is_action_pressed("honk")):
		for object: Area3D in get_tree().get_nodes_in_group("inside_notes"):
			update_scoring(object.score(self))
			object.remove_from_group("inside_notes")
			break
	if (Input.is_action_pressed("drift_left") or Input.is_action_pressed("drift_right")):
		for object: Area3D in get_tree().get_nodes_in_group("inside_drifts"):
			drift_scoring(object.score(self))
			object.remove_from_group("inside_drifts")
			break
	if ((Input.is_action_just_released("drift_left") or Input.is_action_just_released("drift_right")) and drift_on):
		drift_on = false
		drift_score = 0
		for object: Area3D in get_tree().get_nodes_in_group("inside_drifts_ends"):
			update_scoring(object.score(self))
			object.remove_from_group("inside_drift_ends")
			break
	if (drift_on):
		UI.score += drift_score
		
	# Game Over
	if dead:
		$"../..".material.set("shader_parameter/aberration", lerpf($"../..".material.get("shader_parameter/aberration"), 1, delta * 2))
		$"../..".material.set("shader_parameter/warp_amount", lerpf($"../..".material.get("shader_parameter/warp_amount"), 20, delta))
		$"../..".material.set("shader_parameter/vignette_intensity", lerpf($"../..".material.get("shader_parameter/vignette_intensity"), 100, delta / 2))
		$"../..".material.set("shader_parameter/vignette_opacity", lerpf($"../..".material.get("shader_parameter/vignette_opacity"), 1, delta / 4))

func _physics_process(delta: float):
	## Drifting
	var wheel_speed = 20
	$Body/Wheel.rotation_degrees.x += wheel_speed
	$Body/Wheel2.rotation_degrees.x += wheel_speed
	$Body/Wheel3.rotation_degrees.x += wheel_speed
	$Body/Wheel4.rotation_degrees.x += wheel_speed
	if drifting:
		drift(delta)
	else:
		inputs()
	if turn_offset != 0:
		turn_offset = lerpf(turn_offset, 0, delta * 16)
	
	## Movement VFX
	$Body.position.y = lerpf($Body.position.y, 0, delta * 20)
	$Body.rotation.y = lerpf($Body.rotation.y + clampf(turn_offset, -1, 1), $Body.rotation.y - (fmod($Body.rotation.y, (2 * PI)) 
		if abs(turn_offset) < 0.1 else 0.0) - drift_direction, delta * 8)

	## Movement
	position.x = lerpf(position.x, current_lane * 10, delta * 16)
	position.z -= speed * delta

# -1 == left, 1 == right
func drift(delta: float):
	## Params
	drift_time += 1
	
	## Visual Rotation
	#$Body.rotation.y = lerpf($Body.rotation.y, -drift_direction, delta * 5)
	
	## Start of Drift
	if drift_time < 10:
		# Early Drift "Hop"
		$Body.position.y = lerpf($Body.position.y, 1, delta * 30)
		# Spin Turn
		#var spin = Input.get_axis("quick_left", "quick_right")
		#if drift_direction > 0 and spin < 0:
		#	switch_lane(-2)
		#	turn_offset -= 2 * PI
		#if drift_direction < 0 and spin > 0:
		#	switch_lane(2)
		#	turn_offset += 2 * PI

	## Ending
	if (drift_direction < 0 and not Input.is_action_pressed("drift_left"))    \
		or (drift_direction > 0 and not Input.is_action_pressed("drift_right")):
		switch_lane(drift_direction)
		set_drift_graphics("Left", false)
		set_drift_graphics("Right", false)

func update_scoring(hit: Array):
	if (hit[1] != UI.Accuracy.MISS):
		UI.up_scores(hit[1])
	else:
		UI.reset_scores()
		return
	UI.score += hit[0] * UI.multiplier
	
func drift_scoring(hit: Array):
	if (hit[1] != UI.Accuracy.MISS):
		UI.up_scores(hit[1])
	else:
		UI.reset_scores()
		return
	drift_score = hit[0] * UI.multiplier
	drift_on = true

func switch_lane(dir):
	drifting = false
	drift_time = 0
	drift_direction = 0
	var lane_change = ceil(abs(dir))
	if dir < 0 and current_lane > lane_change:
		current_lane -= lane_change
		return
	if dir > 0 and current_lane <= lanes - lane_change:
		current_lane += lane_change
		return
	# Try again
	if lane_change > 1:
		switch_lane(dir / 2)

func inputs():
	if Input.is_action_just_pressed("drift_left"):
		drifting = true
		drift_direction = -1
		set_drift_graphics("Left", true)
		set_drift_graphics("Right", false)
	elif Input.is_action_just_pressed("drift_right"):
		drifting = true
		drift_direction = 1
		set_drift_graphics("Left", false)
		set_drift_graphics("Right", true)
	elif Input.is_action_just_pressed("quick_left"):
		turn_offset = 0.1
		switch_lane(-1)
	elif Input.is_action_just_pressed("quick_right"):
		turn_offset = -0.1
		switch_lane(1)

func _on_area_entered(area: Area3D):
	# dealing with tap_notes
	if (area.is_in_group("tap_notes")):
		area.add_to_group("inside_notes")
		return
	# dealing with drift_notes
	if (area.is_in_group("drift_notes")):
		area.add_to_group("inside_drifts")
		return
	# dealing with the end tiles of drift_notes
	if (area.is_in_group("drift_ends")):
		area.add_to_group("inside_drift_ends")
		return
	# running into an obstacle that ends the game
	if (area.is_in_group("hard_obstacles")):
		UI.current_accuracy = UI.Accuracy.NONE
		print("game over")
		dead = true
		speed = 0
		await get_tree().create_timer(1.5, false).timeout
		get_tree().change_scene_to_file("res://Scenes/Menus/death_screen.tscn")
		
func set_drift_graphics(direction: String, active: bool):
	for child in get_node(NodePath("Body/" + direction + "DriftParticles")).get_children():
		child.emitting = active

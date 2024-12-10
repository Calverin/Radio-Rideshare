extends Area3D

@export_enum("Slow:30", "Average:60", "Very Fast:200") var speed: int
var lanes: int
var current_lane: int

var drifting: bool = false
var drift_time: int = 0
var drift_direction: float = 0
var turn_offset: float = 0
var score: int = 0

func _ready():
	lanes = LevelLoader.current_level.lanes
	current_lane = ceil(float(lanes) / 2)
	position.x = current_lane * 10

func _process(_delta: float):
	if(Input.is_action_pressed("honk")):
		for object: Node3D in get_tree().get_nodes_in_group("inside_notes"):
			print("notesssnotesss")
			score += object.score(self)
			break
	if(Input.is_action_pressed("drift_left")):
		for object in get_tree().get_nodes_in_group("left_drifts"):
			if(object.isactive()):
				score += object.score(self)
	if(Input.is_action_pressed("drift_right")):
		for object in get_tree().get_nodes_in_group("right_drifts"):
			if(object.isactive()):
				score += object.score(self)

func _physics_process(delta: float):
	## Drifting
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
		var spin = Input.get_axis("quick_left", "quick_right")
		if drift_direction > 0 and spin < 0:
			switch_lane(-2)
			turn_offset -= 2 * PI
		if drift_direction < 0 and spin > 0:
			switch_lane(2)
			turn_offset += 2 * PI

	## Ending
	if (drift_direction < 0 and not Input.is_action_pressed("drift_left"))    \
		or (drift_direction > 0 and not Input.is_action_pressed("drift_right")):
		switch_lane(drift_direction)

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
	elif Input.is_action_just_pressed("drift_right"):
		drifting = true
		drift_direction = 1
	elif Input.is_action_just_pressed("quick_left"):
		turn_offset = 0.1
		switch_lane(-1)
	elif Input.is_action_just_pressed("quick_right"):
		turn_offset = -0.1
		switch_lane(1)

func _on_area_entered(area: Area3D):
	# entering the body of a tapnote
	if (area.is_in_group("tap_notes")):
		print("added to group")
		area.add_to_group("inside_notes")
		pass
	# running into an obstacle that ends the game
	if (area.is_in_group("hard_obstacles")):
		print("game over")
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	pass

func _on_area_exited(area: Area3D):
	if (area.is_in_group("inside_notes")):
		print("removing from group")
		area.remove_from_group("inside_notes")
	pass

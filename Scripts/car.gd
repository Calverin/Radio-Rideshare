extends CharacterBody3D

@export_enum("Slow:30", "Average:60", "Very Fast:200") var speed: int
@export_enum("Local Road:1", "City Street:3", "Highway:5") var lanes: int

var drifting: bool = false
var drift_time: int = 0
var drift_direction: String = ""

var current_lane: int = ceil(lanes/2)

func _physics_process(delta: float):
	
	if Input.is_action_just_pressed("drift") and not drifting:
		drifting = true

	if drifting:
		drift(delta)
		
	position.x = current_lane * 10
	position.z -= speed * delta
	
func drift(delta: float):
	var axis = Input.get_axis("steer_left", "steer_right")
	drift_direction = "left" if axis < 0 else "right" if axis > 0 else ""
	$Body.rotation.y = lerp($Body.rotation.y, axis * 90, delta)
	if not Input.is_action_pressed("drift"):
		drifting = false
		switch_lane()
		
func switch_lane():
	if drift_direction == "left" and current_lane > 1:
		current_lane -= 1
	if drift_direction == "right" and current_lane < lanes:
		current_lane += 1

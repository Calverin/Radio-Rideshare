extends CharacterBody3D

@export_enum("Slow:30", "Average:60", "Very Fast:200") var speed: int
@onready var lanes: int = $"../Road".lane_count
var current_lane: int

var drifting: bool = false
var drift_time: int = 0
var drift_direction: int = 0

func _ready():
	current_lane = ceilf(lanes / 2.0)
	position.x = current_lane * 10

func _physics_process(delta: float):
	## Drifting
	if Input.is_action_just_pressed("drift") and not drifting:
		drifting = true
		drift_direction = 0
	if drifting:
		drift(delta)
	else:
		$Body.rotation.y = lerpf($Body.rotation.y, 0, delta * 6)
		if Input.is_action_just_pressed("steer_left"):
			$Body.rotation.y += 0.25
			switch_lane(-1)
		if Input.is_action_just_pressed("steer_right"):
			$Body.rotation.y -= 0.25
			switch_lane(1)
			
		
	
	## Movement
	position.x = lerpf(position.x, current_lane * 10, delta * 20)
	$Body.position.y = lerpf($Body.position.y, 1.5, delta * 20)
	position.z -= speed * delta
	
func drift(delta: float):
	## Params
	var axis = Input.get_axis("steer_left", "steer_right")
	# -1 == left, 1 == right
	drift_direction = -1 if axis < 0 else 1 if axis > 0 else drift_direction
	drift_time += 1
	
	## VFX
	$Body.rotation.y = lerpf($Body.rotation.y, -drift_direction, delta * 5)
	# Early Drift "Hop"
	if drift_time < 10:
		$Body.position.y = lerpf($Body.position.y, 2.5, delta * 30)
	## Ending
	if not Input.is_action_pressed("drift"):
		drifting = false
		drift_time = 0
		switch_lane(drift_direction)
		
func switch_lane(dir):
	if dir == -1 and current_lane > 1:
		current_lane -= 1
	if dir == 1 and current_lane < lanes:
		current_lane += 1

extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0

@export var engine_force_value := 40.0

var previous_speed := linear_velocity.length()
var _steer_target := 0.0

func _physics_process(delta: float):
	var fwd_mps := (linear_velocity * transform.basis).x

	_steer_target = Input.get_axis("steer_right", "steer_left")
	_steer_target *= STEER_LIMIT

	if abs(linear_velocity.length() - previous_speed) > 1.0:
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)

	if Input.is_action_pressed("accelerate"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value

		#if not DisplayServer.is_touchscreen_available():
			# Apply analog throttle factor for more subtle acceleration if not fully holding down the trigger.
			#engine_force *= Input.get_action_strength("accelerate")
	else:
		engine_force = 0.0

	if Input.is_action_pressed("reverse"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * BRAKE_STRENGTH * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value * BRAKE_STRENGTH

		# Apply analog brake factor for more subtle braking if not fully holding down the trigger.
		engine_force *= Input.get_action_strength("reverse")

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()

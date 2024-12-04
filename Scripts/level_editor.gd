extends Node

var current_tile: Vector2i

var current_level: Level
var level_data
var level_length: int

@onready var LOADER = $Loader
@onready var GROUND = $Level/Ground.mesh
@onready var HIGHLIGHT: MeshInstance3D = $Level/Highlight

func _ready() -> void:
	var level = LevelLoader.current_level_name
	if not level:
		return
	print("Starting to edit level: " + level)
	current_level = LOADER.load_level(level)
	
	var lanes = current_level.lanes
	GROUND.size.x = lanes * 10
	GROUND.material.uv1_scale.x = lanes
	
	current_tile = Vector2i((lanes / 2), 0)
	
	level_data = current_level.data
	level_length = len(level_data)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_up")):
		current_tile.y = min(current_tile.y + 1, level_length - 1)
	if (Input.is_action_just_pressed("ui_down")):
		current_tile.y = max(current_tile.y - 1, 0)
	if (Input.is_action_just_pressed("ui_left")):
		current_tile.x = max(current_tile.x - 1, 0)
	if (Input.is_action_just_pressed("ui_right")):
		current_tile.x = min(current_tile.x + 1, current_level.lanes - 1)
	
	var speed = delta * 10
	HIGHLIGHT.position = Vector3(lerpf(HIGHLIGHT.position.x, current_tile.x * 10 - (current_level.lanes / 2) * 10, speed), 1, lerpf(HIGHLIGHT.position.z, current_tile.y * -10, speed))

		

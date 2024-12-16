extends Node

var current_tile: Vector2i

var current_level: Level
var level_data
var level_length: int

@onready var LOADER = $Loader
@onready var GROUND = $Level/Ground.mesh
@onready var HIGHLIGHT: MeshInstance3D = $Level/Highlight
@onready var NOTES = $Level/Notes

var TAP_NOTE = preload("res://Scenes/Notes/tap_note.tscn")
var PARKED_CAR = preload("res://Scenes/Obstacles/parked_car.tscn")

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
	if Input.is_action_just_pressed("ui_up"):
		current_tile.y = min(current_tile.y + 1, level_length - 1)
	if Input.is_action_just_pressed("ui_down"):
		current_tile.y = max(current_tile.y - 1, 0)
	if Input.is_action_just_pressed("ui_left"):
		current_tile.x = max(current_tile.x - 1, 0)
	if Input.is_action_just_pressed("ui_right"):
		current_tile.x = min(current_tile.x + 1, current_level.lanes - 1)
	
	var speed = delta * 10
	HIGHLIGHT.position = Vector3(lerpf(HIGHLIGHT.position.x, current_tile.x * 10 - (current_level.lanes / 2) * 10, speed), 1, lerpf(HIGHLIGHT.position.z, current_tile.y * -10, speed))

	if Input.is_action_just_pressed("object_1"):
		insert_object(TAP_NOTE, 1)
	if Input.is_action_just_pressed("object_2"):
		insert_object(PARKED_CAR, 2)
		
	if Input.is_action_just_pressed("object_clear"):
		insert_object(null, 0)
		
	if Input.is_action_just_pressed("exit"):
		save_level()
		get_tree().change_scene_to_file("res://Scenes/Menus/level_selector.tscn")
		

func insert_object(scene: PackedScene, id: int):
	# Remove all nodes at that position already:
	for child in NOTES.get_children():
		if child.name.begins_with(str(current_tile)):
			child.queue_free()
			NOTES.remove_child(child)
			break
	
	# Add the new node to the level data
	print(level_data)
	var line = level_data[current_tile.y].split()
	line[current_tile.x] = str(id)
	level_data[current_tile.y] = "".join(line)
	
	if scene == null:
		return 
	# Add the new node to the level itself
	var obj: Node = scene.instantiate()
	obj.position = Vector3(current_tile.x * 10 - (current_level.lanes / 2) * 10, 1, current_tile.y * -10)
	obj.name = str(current_tile) + obj.name
	NOTES.add_child(obj)

func save_level():
	current_level.data = level_data
	LevelLoader.save_level_data(current_level)

extends Node

var current_tile: Vector2i

var current_level: Level
var level_data: Array
var level_length: int

var song_length: float
var song_position: float = 0.0
var nps: float

@onready var LOADER = $Loader
@onready var GROUND = $Level/Ground
@onready var VIEW = $Level/View
@onready var OBJECTS = $Level/Objects

var BAR = preload("res://Scenes/bar.tscn")
var TAP_NOTE = preload("res://Scenes/Notes/tap_note.tscn")
var DRIFT_LEFT = preload("res://Scenes/Notes/drift_left.tscn")
var DRIFT_RIGHT = preload("res://Scenes/Notes/drift_right.tscn")
var DRIFT_RELEASE = preload("res://Scenes/Notes/drift_release.tscn")
var PARKED_CAR = preload("res://Scenes/Obstacles/parked_car.tscn")

func _ready() -> void:
	var lanes_node = $UI/RightSidebar/Container/Lanes
	lanes_node.get_node("Add").pressed.connect(_on_add_lane_pressed.bind(lanes_node.get_node("Amount")))
	lanes_node.get_node("Subtract").pressed.connect(_on_subtract_lane_pressed.bind(lanes_node.get_node("Amount")))
	var nps_node = $UI/RightSidebar/Container/NPS
	nps_node.get_node("Add").pressed.connect(_on_add_nps_pressed.bind(nps_node.get_node("Amount")))
	nps_node.get_node("Subtract").pressed.connect(_on_subtract_nps_pressed.bind(nps_node.get_node("Amount")))
	reload_level()
	
func reload_level() -> void:
	# Loading data
	var starting_tile = Vector2i(current_tile)
	clear_objects()
	var level = LevelLoader.current_level_name
	if not level:
		return
	print("(Re)Loading level editor with: " + level)
	current_level = LOADER.load_level(level)
	var lanes = current_level.lanes
	nps = float(current_level.nps)
	
	# Load the song and get its length in seconds
	song_length = $Song.load_song()
	var proper_length: int = ceil(song_length * float(nps))
	
	# Set up UI data
	$UI/RightSidebar/Container/LevelName.text = current_level.title
	$UI/RightSidebar/Container/Lanes/Amount.text = str(lanes)
	$UI/RightSidebar/Container/NPS/Amount.text = str(nps)
	$UI/LeftSidebar/Completion.min_value = 0
	$UI/LeftSidebar/Completion.max_value = song_length
	if (not starting_tile):
		starting_tile = Vector2i((lanes / 2), 0)
		
	# Set ground size
	GROUND.mesh.size.x = lanes * 10
	GROUND.mesh.material.uv1_scale.x = lanes
	VIEW.get_node("PlayBar").mesh.size.x = lanes * 10
	
	
	level_data = current_level.data
	level_length = len(level_data)
	
	# Check if there's a mismatch in song length, should probably also account for too long levels but ignoring for now
	if proper_length > level_length:
		for i in range(proper_length - level_length):
			level_data.append("".rpad(lanes, "0"))
		save_level()
	
	if level_length > proper_length:
		for i in range(proper_length, level_length):
			level_data.remove_at(i)
		save_level()
	level_length = proper_length
	
	# Insert initial objects
	for i in range(level_length):
		# Bars
		if (i % current_level.nps == 0):
			var b = BAR.instantiate()
			b.position = Vector3(0, 0, i * -10 + 8000)
			b.mesh.size.x = lanes * 10
			b.name += str(i / current_level.nps)
			GROUND.add_child(b)
		# Objects
		var line = level_data[i].split()
		for o in range(len(line)):
			if line[o] != '0':
				current_tile = Vector2i(o, i)
			match line[o]:
				'1':
					insert_object(TAP_NOTE, 1)
				'2':
					insert_object(PARKED_CAR, 2)
				'3':
					insert_object(DRIFT_LEFT, 3)
				'4':
					insert_object(DRIFT_RIGHT, 4)
				'5':
					insert_object(DRIFT_RELEASE, 5)

	current_tile = Vector2i(starting_tile)
	
func clear_objects():
	for child in OBJECTS.get_children():
		OBJECTS.remove_child(child)
		child.free()
	for child in GROUND.get_children():
		GROUND.remove_child(child)
		child.free()
	#if len(OBJECTS.get_children()) > 0:
	#	clear_objects()
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		save_level()
		get_tree().change_scene_to_file("res://Scenes/Menus/level_selector.tscn")
	
	# Toggling the song
	if Input.is_action_just_pressed("toggle_music"):
		toggle_music()
	
	# Scrolling
	$UI/LeftSidebar/Completion.value = song_position + 1
	if Input.is_action_just_released("scroll_up"):
		song_position = min(song_length, song_position + 0.1)
		current_tile.y = floor(song_position * nps)
		if $Song.playing:
			$Song.play(song_position)
	if Input.is_action_just_released("scroll_down"):
		song_position = max(0.0, song_position - 0.1)
		current_tile.y = ceil(song_position * nps)
		if $Song.playing:
			$Song.play(song_position)
	
	if $Song.playing:
		song_position = $Song.get_playback_position()
		VIEW.position = Vector3(0, 1, lerpf(VIEW.position.z, -song_position * 10.0 * nps, delta * 20))
		if (song_length - song_position < 1):
			toggle_music()
		return
			
	### BELOW HERE IS ONLY WHEN SONG IS NOT PLAYING ###
	var speed = delta * 10
	if Input.is_action_just_released("scroll_up"):
		current_tile.y = min(current_tile.y + 1, level_length - 1)
	if Input.is_action_just_released("scroll_down"):
		current_tile.y = max(current_tile.y - 1, 0)
	if Input.is_action_just_released("scroll_left"):
		current_tile.x = max(current_tile.x - 1, 0)
	if Input.is_action_just_released("scroll_right"):
		current_tile.x = min(current_tile.x + 1, current_level.lanes - 1)
	VIEW.position = Vector3(lerpf(VIEW.position.x, current_tile.x * 10 - (current_level.lanes / 2) * 10, speed), 1, lerpf(VIEW.position.z, current_tile.y * -10, speed))

	if Input.is_action_just_pressed("object_1"):
		insert_object(TAP_NOTE, 1)
	if Input.is_action_just_pressed("object_2"):
		insert_object(PARKED_CAR, 2)
	if Input.is_action_just_pressed("object_3"):
		insert_object(DRIFT_LEFT, 3)
	if Input.is_action_just_pressed("object_4"):
		insert_object(DRIFT_RIGHT, 4)
	if Input.is_action_just_pressed("object_5"):
		insert_object(DRIFT_RELEASE, 5)
		
	if Input.is_action_just_pressed("object_clear"):
		insert_object(null, 0)
	
	song_position = current_tile.y / nps
		
func insert_object(scene: PackedScene, id: int):
	# Remove all nodes at that position already:
	for child in OBJECTS.get_children():
		if child.name.begins_with(str(current_tile)):
			child.queue_free()
			OBJECTS.remove_child(child)
			break
	
	# Add the new node to the level data
	#print(level_data)
	var line = level_data[current_tile.y].split()
	line[current_tile.x] = str(id)
	level_data[current_tile.y] = "".join(line)
	
	if scene == null:
		return 
	# Add the new node to the level itself
	var obj: Node = scene.instantiate()
	obj.position = Vector3(current_tile.x * 10 - (current_level.lanes / 2) * 10, 1, current_tile.y * -10 - 5)
	obj.name = str(current_tile) + obj.name
	OBJECTS.add_child(obj)

func save_level():
	current_level.data = level_data
	current_level.lanes = len(level_data[0])
	current_level.nps = int(nps)
	LevelLoader.save_level_data(current_level)

func toggle_music():
	if $Song.playing:
		VIEW.get_node("PlayBar").visible = false
		VIEW.get_node("Highlight").visible = true
		current_tile = Vector2i(current_level.lanes / 2, floor(song_position * nps))
		VIEW.position = Vector3(current_tile.x * 10 - (current_level.lanes / 2) * 10, 1, current_tile.y * -10)
		$Song.stop()
	else:
		$Song.play(song_position)
		VIEW.get_node("PlayBar").visible = true
		VIEW.get_node("Highlight").visible = false

func _on_add_lane_pressed(amount: Node) -> void:
	var lanes = current_level.lanes
	for i in range(len(level_data)):
		level_data[i] = "0" + level_data[i] + "0"
	
	amount.text = str(lanes + 2)
	current_tile.x = (lanes + 2) / 2
	save_level()
	reload_level()

func _on_subtract_lane_pressed(amount: Node) -> void:
	var lanes = current_level.lanes
	if (lanes == 1):
		return
	for i in range(len(level_data)):
		level_data[i] = level_data[i].substr(1, lanes - 2)
		
	amount.text = str(lanes - 2)
	current_tile.x = (lanes - 2) / 2
	
	save_level()
	reload_level()

func _on_subtract_nps_pressed(amount: Node) -> void:
	nps = current_level.nps
	if (nps == 1):
		return
	nps -= 1
	
	amount.text = str(nps)
	current_tile.y = 0 # Not even dealing with this
	
	save_level()
	reload_level()

func _on_add_nps_pressed(amount: Node) -> void:
	nps += 1
	
	amount.text = str(nps)
	current_tile.y = 0 # Not even dealing with this
	
	save_level()
	reload_level()

extends Node

var current_level: Level
var size: int

## Obstacles
#var PARKED_CAR = preload("res://Scenes/parked_car.tscn")
#var LEFT_SIGN = preload("res://Scenes/sign_left.tscn")
	
class Level:
	@export var title: String = ""
	@export var artist: String = ""
	@export var mapper: String = ""
	@export var nps: int = 1
	@export var lanes: int = 3
	@export var data = []
	
static func load_level(name: String) -> Level:
	var level = Level.new()
	var data = []
	var headers = []
	
	## Load level
	var data_string = load_level_data(name)
	data = data_string.split("\n")
	for s: String in data:
		if s.begins_with("#"):
			headers.append(s.replace("#",""))
		elif not s.strip_escapes().is_empty():
			level.data.append(s)
	
	## Process headers
	for h: String in headers:
		if h.begins_with("TITLE"):
			level.title = h.split(":")[1]
		if h.begins_with("ARTIST"):
			level.artist = h.split(":")[1]
		if h.begins_with("MAPPER"):
			level.mapper = h.split(":")[1]
		if h.begins_with("NPS"):
			level.nps = int(h.split(":")[1])
		if h.begins_with("LANES"):
			level.lanes = int(h.split(":")[1])
	return level

func generate_level(grid: GridMap, level: Level) -> void:
	size = grid.cell_scale
	var length = len(level.data)
	## Generate level
	for i in range(length):
		## Road
		var z = -i * size
		# Left road side
		grid.set_cell_item(Vector3i(0, 0, z), 0)
		# Center
		var x = size
		for o in range(level.lanes - 2):
			grid.set_cell_item(Vector3i(x, 0, z), 1)
			x += size
		# Right side (10 is a flipped rotation on the y axis, don't ask y...)
		grid.set_cell_item(Vector3i(x + size, 0, z - size), 0, 10)
		## Obstacles
		var obstacles = level.data[i].split()
		for o in range(level.lanes):
			if obstacles[o] == '1':
				pass

static func load_level_data(name) -> String:
	var path = "user://Levels/" + name + "/" + name + ".rrl"
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content
	
static func find_level_icon(name) -> Texture2D:
	var path = "user://Levels/" + name + "/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var image = Image.new()
				image.load(path + file_name)
				if not image.is_empty():
					var icon = ImageTexture.new()
					return icon.create_from_image(image)
			file_name = dir.get_next()
	return

func insert_obstacle(obstacle: PackedScene, z: int, lane: int) -> void:
	var child: Node3D = obstacle.instantiate()
	child.position = Vector3(lane * 10, 3, z * size)
	add_child(child)

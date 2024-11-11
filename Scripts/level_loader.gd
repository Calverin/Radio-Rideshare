extends GridMap

@export var lane_count: int = 3
@export var song_length: String
@export var nps: int = 1

var size: int

var data = []
var headers = []
var level_data = []

## Obstacles
var PARKED_CAR = preload("res://Scenes/parked_car.tscn")
var LEFT_SIGN = preload("res://Scenes/sign_left.tscn")

func _ready() -> void:
	size = cell_scale
	
	## Load level
	var data_string = load_from_file("res://Levels/Scarlet Fire/Scarlet Fire.rrl")
	data = data_string.split("\n")
	for s: String in data:
		if s.begins_with("#"):
			headers.append(s.replace("#",""))
		elif not s.strip_escapes().is_empty():
			level_data.append(s)
	
	## Process headers
	for h: String in headers:
		if h.begins_with("LANES"):
			lane_count = int(h.split(":")[1])
		if h.begins_with("SONG_LENGTH"):
			song_length = h.split(":")[1]
		if h.begins_with("NPS"):
			nps = int(h.split(":")[1])
			
	var length = len(level_data)
	## Generate level
	for i in range(length):
		## Road
		var z = -i * size
		# Left road side
		set_cell_item(Vector3i(0, 0, z), 0)
		# Center
		var x = size
		for o in range(lane_count-2):
			set_cell_item(Vector3i(x, 0, z), 1)
			x += size
		# Right side (10 is a flipped rotation on the y axis, don't ask y...)
		set_cell_item(Vector3i(x + size, 0, z - size), 0, 10)
		## Obstacles
		var obstacles = level_data[i].split()
		for o in range(lane_count):
			if obstacles[o] == '1':
				insert_obstacle(LEFT_SIGN, z, o)
			if obstacles[o] == '2':
				# Accounting for weird offset
				insert_obstacle(PARKED_CAR, z, o + 1)
				



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_from_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content

func insert_obstacle(obstacle: PackedScene, z: int, lane: int):
	var child: Node3D = obstacle.instantiate()
	child.position = Vector3(lane * 10, 5, z * size)
	add_child(child)

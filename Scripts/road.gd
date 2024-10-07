extends GridMap

@export var lane_count: int = 3
var size: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = cell_scale
	for i in range(50):
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

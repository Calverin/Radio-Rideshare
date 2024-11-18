extends Area3D

@onready var lanes: int = $"../Road".lane_count
var current_lane: int

# Called when the node enters the scene tree for the first time.
func _ready():
	current_lane = ceilf(lanes / 2.0)
	position.x = current_lane * 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

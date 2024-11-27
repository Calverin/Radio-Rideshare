extends Node

var current_tile: Vector2i

var current_level: Level

@onready var LOADER = $Loader

func _ready() -> void:
	var level = LevelLoader.current_level_name
	if level:
		print("Starting to edit level: " + level)
		current_level = LOADER.load_level(level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

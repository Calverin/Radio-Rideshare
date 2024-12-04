extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load song
	var song: AudioStreamMP3 = LevelLoader.find_level_song(LevelLoader.current_level.title)
	stream = song
	if get_parent().name == "World":
		play()

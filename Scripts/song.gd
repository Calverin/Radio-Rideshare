extends AudioStreamPlayer

func load_song() -> float:
	# Load song
	var song: AudioStreamMP3 = LevelLoader.find_level_song(LevelLoader.current_level.title)
	stream = song
	
	# Probably temporary lol but speeds up the song relative to NPS above 4
	#pitch_scale = 1 + ((float(LevelLoader.current_level.nps) / 4.0) - 1) / 20.0
	
	# Start song automatically for gameplay
	if get_parent().name == "World":
		play()
	
	return song.get_length()
	

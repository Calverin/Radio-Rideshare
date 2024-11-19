extends Control

var levels
var LEVEL_LISTING = preload("res://Scenes/Menus/level_listing.tscn")

func _ready() -> void:
	refresh_level_list()

func refresh_level_list():
	levels = []
	# Load all levels in Level folder and make a Level Listing for each one
	var dir = DirAccess.open("user://Levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				levels.append(file_name)
			file_name = dir.get_next()

	for name in levels:
		# Load level data
		var level = $Loader.load_level(name)
		if level.title == "":
			continue
		
		# Find icon
		var icon = $Loader.find_level_icon(name)
		
		# Create listing
		var listing = LEVEL_LISTING.instantiate()
		listing.name = level.title
		$Levels.add_child(listing)
		
		# Apply data
		for child in listing.get_children():
			if child is Label:
				child.text = level.title
			if child is TextureRect and icon:
				child.texture = icon
				
		if icon:
			listing.get_child(0).texture = icon
		

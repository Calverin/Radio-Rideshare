extends Control

var levels
var LEVEL_LISTING = preload("res://Scenes/Menus/level_listing.tscn")

func _ready() -> void:
	refresh_level_list()

func _process(delta):
	material.set("shader_parameter/aberration", lerpf(material.get("shader_parameter/aberration"), 0, delta * 2))
	
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

	for file_name in levels:
		# Load level data
		var level = $Loader.load_level(file_name)
		if level.title == "":
			continue
		
		# Find icon
		var icon = $Loader.find_level_icon(file_name)
		
		# Create listing
		var listing = LEVEL_LISTING.instantiate()
		listing.name = level.title
		$Levels.add_child(listing)
		
		# Apply data
		for child in listing.get_children():
			if child is Label:
				if child.name == "Title":
					child.text = level.title
				if child.name == "Artist":
					child.text = "By: " + level.artist
				if child.name == "Mapper":
					child.text = "[" + level.mapper + "]"
				if child.name == "NPS":
					child.text = "NPS: " + str(level.nps)
			if child is TextureRect and icon:
				child.texture = icon
			if child is Button:
				if child.name == "PlayButton":
					(child as Button).pressed.connect(_on_play_level.bind(level.title))
				if child.name == "EditButton":
					(child as Button).pressed.connect(_on_edit_level.bind(level.title))
		
func _on_play_level(level_name: String):
	LevelLoader.current_level_name = level_name
	material.set("shader_parameter/aberration", 0)
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
	
func _on_edit_level(level_name: String):
	LevelLoader.current_level_name = level_name
	material.set("shader_parameter/aberration", 0)
	get_tree().change_scene_to_file("res://Scenes/level_editor.tscn")

extends Node3D
var active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func isactive():
	return active
	

func score(playerbox):
	if(get_node("Good").overlaps_area(playerbox)):
		if(get_node("Great").overlaps_area(playerbox)):
			if(get_node("Perfect").overlaps_area(playerbox)):
				return 300
				active = false
			return 200
			active = false
		return 100
		active = false
	return 0
	
	
				

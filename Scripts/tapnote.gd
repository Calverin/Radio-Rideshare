extends Node3D
var active = true
	
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

extends Node3D

func score(playerbox: Area3D) -> int:
	print("Scoring!")
	if ($Good.overlaps_area(playerbox)):
		if ($Great.overlaps_area(playerbox)):
			if ($Perfect.overlaps_area(playerbox)):
				queue_free()
				return 300
			queue_free()
			return 200
		queue_free()
		return 100
	queue_free()
	return 0

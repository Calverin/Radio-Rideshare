extends Area3D

func score(playerbox: Area3D) -> Array:
	if ($Good.overlaps_area(playerbox)):
		if ($Great.overlaps_area(playerbox)):
			if ($Perfect.overlaps_area(playerbox)):
				return [300, "Perfect"]
			return [200, "Great"]
		return [100, "Good"]
	queue_free()
	return [0, "Miss"]

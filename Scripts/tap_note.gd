extends Area3D

func score(playerbox: Area3D) -> int:
	if ($Good.overlaps_area(playerbox)):
		print("wahoo!")
		if ($Great.overlaps_area(playerbox)):
			if ($Perfect.overlaps_area(playerbox)):
				queue_free()
				return 300
			queue_free()
			return 200
		queue_free()
		return 100
	return 0

extends Node3D

func score(playerbox: Area3D) -> int:
	if ($Good.overlaps_body(playerbox)):
		print("wahoo!")
		if ($Great.overlaps_body(playerbox)):
			if ($Perfect.overlaps_body(playerbox)):
				queue_free()
				return 300
			queue_free()
			return 200
		queue_free()
		return 100
	queue_free()
	return 0

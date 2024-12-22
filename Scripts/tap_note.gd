extends Area3D

func score(playerbox: Area3D) -> Array:
	if ($Good.overlaps_area(playerbox)):
		if ($Great.overlaps_area(playerbox)):
			if ($Perfect.overlaps_area(playerbox)):
				return [300, UI.Accuracy.PERFECT]
			return [200, UI.Accuracy.GREAT]
		return [100, UI.Accuracy.GOOD]
	queue_free()
	return [0, UI.Accuracy.MISS]
	

func _on_area_exited(_area):
	if (is_in_group("inside_notes")):
		UI.current_accuracy = UI.Accuracy.MISS
		remove_from_group("inside_notes")

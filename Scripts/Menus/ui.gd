extends Node

var default_score: String = "SCORE: "
var score: int = 0


var default_streak: String = "STREAK: "
var streak: int = 0;

var default_multiplier: String = "  MULTIPLIER: "
var multiplier: int = 1
var x: String = "x"
var colors: Array = [
	Color(0, 0, 0, 0), # buffer
	Color(1.0, 1.0, 1.0, 1.0), # white / 1x
	Color(0.396, 0.992, 0.447, 1.0), # green / 2x
	Color(0.396, 0.765, 0.992, 1.0), # blue / 3x
	Color(1.0, 0.843, 0.0, 1.0) # gold / 4x
]

enum Accuracy {MISS, GOOD, GREAT, PERFECT, NONE}
var current_accuracy: Accuracy = Accuracy.NONE
var accuracies: Array[Object] = [
	preload("res://Assets/Texts/Miss.png"),
	preload("res://Assets/Texts/Good.png"),
	preload("res://Assets/Texts/Great.png"),
	preload("res://Assets/Texts/Perfect.png")
]
var image = Image.new()

func _process(delta):
	if (len(get_children()) <= 0):
		return
	$Score.text = str(default_score, UI.score)
	$BelowScore/Streak.text = str(default_streak, UI.streak)
	$BelowScore/Multiplier.text = str(default_multiplier, UI.multiplier, x)
	$BelowScore/Multiplier.label_settings.font_color = colors[UI.multiplier]
	if (UI.current_accuracy != Accuracy.NONE):
		$NoteHit.texture = accuracies[UI.current_accuracy]
		$NoteHit.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		UI.current_accuracy = Accuracy.NONE
	else:
		$NoteHit.self_modulate = Color(1.0, 1.0, 1.0, lerpf($NoteHit.self_modulate.a, 0.0, delta))

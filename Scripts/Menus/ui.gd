extends Node

var default_score: String = "SCORE: "
var score: int = 0


var default_streak: String = "STREAK: "
var streak: int = 0;

var default_multiplier: String = "MULTIPLIER: "
var multiplier: int = 1
var x: String = "x"
var colors: Array[Color] = [
	Color(0, 0, 0, 0),
	Color(255,255,255,255), # white / 1x
	Color(101, 253, 114, 1), # green / 2x
	Color(101, 195, 253, 1), # blue / 3x
	Color(255, 215, 0, 1)# gold / 4x
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

func _process(_delta):
	if (len(get_children()) <= 0):
		return
	$Score.text = str(default_score, UI.score)
	$Multiplier.text = str(default_multiplier, UI.multiplier, x)
	$Multiplier.set("theme_override_colors/default_color", colors[UI.multiplier + 1])
	if (UI.current_accuracy != Accuracy.NONE):
		if (UI.current_accuracy != Accuracy.MISS):
			UI.multiplier = min(max(UI.streak / 10.0 + 1, 1), 4)
		else:
			UI.streak = 0
			UI.multiplier = 1
		$NoteHit.texture = accuracies[UI.current_accuracy]
		$Streak.text = str(default_streak, UI.streak)

extends Node

var score: int = 0
var recent_hit: String = ""

var default_score_text: String = "SCORE: "

enum Accuracy {NONE, MISS, GOOD, GREAT, PERFECT}
var current_accuracy: Accuracy = Accuracy.NONE
var accuracies: Array[String] = [
	"",
	"res://Assets/Texts/Miss.png",
	"res://Assets/Texts/Good.png",
	"res://Assets/Texts/Great.png",
	"res://Assets/Texts/Perfect.png"
]
var image = Image.new()

func _process(_delta):
	if (len(get_children()) <= 0):
		return
	$Score.text = str(default_score_text, UI.score)
	if (UI.current_accuracy != Accuracy.NONE):
		UI.image.load(accuracies[UI.current_accuracy])
		$NoteHit.texture = ImageTexture.create_from_image(UI.image)
	
#preload("res://Assets/Texts/Miss.png"),
#	preload("res://Assets/Texts/Good.png"),
#	preload("res://Assets/Texts/Great.png"),

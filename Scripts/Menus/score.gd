extends RichTextLabel

var default_text = "CURRENT SCORE: "

func _process(_delta):
	text = str(default_text, $"../..".score);

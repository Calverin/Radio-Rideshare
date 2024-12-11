extends RichTextLabel

var default_text = " "

func _process(_delta):
	text = str(default_text, $"../..".recent_hit);

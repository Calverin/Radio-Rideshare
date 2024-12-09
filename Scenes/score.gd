extends RichTextLabel

var default_text = "CURRENT SCORE: "

func _process(delta):
	var text = str(default_text, $"../..".score);
	self.text = (text)

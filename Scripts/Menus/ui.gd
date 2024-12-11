extends Node

var score: int = 0
var recent_hit: String = ""


var default_score_text: String = "SCORE: "
var default_last_note_text: String = ""

func _process(_delta):
	if (len(get_children()) <= 0):
		return
	$Score.text = str(default_score_text, UI.score);
	$NoteHit.text = str(default_last_note_text, UI.recent_hit);

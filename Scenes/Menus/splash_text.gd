extends Label

var texts: Array[String] = [
	"You shouldn't park there",
	"You drive like a grandmother",
	"on your learners?",
	"try again later <3",
	"a win is just around the corner",
	"your insurance company is so happy right now"
]

func _ready():
	text = texts.pick_random()

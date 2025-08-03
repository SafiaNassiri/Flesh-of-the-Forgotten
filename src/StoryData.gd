extends Node

const STORY = {
	"start": {
		"text": "You wake up in a forgotten place. Shadows whisper around you.",
		"choices": [
			{ "text": "Look around", "next": "look" },
			{ "text": "Stay still", "next": "wait" }
		]
	},
	"look": {
		"text": "You see a worn door and a staircase into darkness.",
		"choices": [
			{ "text": "Open the door", "next": "door" },
			{ "text": "Take the stairs", "next": "stairs" }
		]
	},
	"wait": {
		"text": "The whispering grows louder... something is coming.",
		"choices": [
			{ "text": "Run!", "next": "run" }
		]
	},
	"door": {
		"text": "The door creaks open into blinding light.",
		"choices": []
	},
	"stairs": {
		"text": "You descend into darkness.",
		"choices": []
	},
	"run": {
		"text": "You sprint blindly into the unknown.",
		"choices": []
	}
}

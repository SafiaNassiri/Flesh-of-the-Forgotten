extends Node

var locations = {
	"awakening": {
		"description": "You awaken in the Bone Orchard, moonlight pouring over hollow trees.",
		"options": [
			{"text": "Accept the godling's whisper", "next": "accept_godling"},
			{"text": "Resist the voice", "next": "resist_godling"}
		]
	},
	"accept_godling": {
		"description": "The godling coils into your bones. Power, and rot.",
		"options": [
			{"text": "Feed on the rotkin", "next": "feed_rotkin"},
			{"text": "Spare your companion", "next": "spare_companion"}
		]
	},
	# Add more here...
}

func get_location(id: String) -> Dictionary:
	return locations.get(id, {})

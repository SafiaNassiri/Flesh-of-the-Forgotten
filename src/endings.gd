extends Node

var unlocked_endings = []

func save_ending(ending_id: String):
	if ending_id in unlocked_endings:
		return
	unlocked_endings.append(ending_id)
	var file = FileAccess.open("user://endings.save", FileAccess.WRITE)
	file.store_var(unlocked_endings)
	file.close()

func load_endings():
	if FileAccess.file_exists("user://endings.save"):
		var file = FileAccess.open("user://endings.save", FileAccess.READ)
		unlocked_endings = file.get_var()
		file.close()

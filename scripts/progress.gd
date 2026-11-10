extends Node

const PATH = "user://progress.json"
var data: Dictionary = {"language": "tr", "sound": true, "languages": {}}
var save_error := false

func _ready() -> void:
	if FileAccess.file_exists(PATH):
		var loaded = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if loaded is Dictionary and loaded.get("languages") is Dictionary:
			data.merge(loaded, true)
	if data.language in Languages.CODES:
		Languages.current = data.language

func state() -> Dictionary:
	var code = Languages.current
	if not data.languages.has(code):
		data.languages[code] = {"completed": [], "sessions": {}, "mistakes": 0}
	return data.languages[code]

func save() -> void:
	data.language = Languages.current
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	save_error = file == null
	if file:
		file.store_string(JSON.stringify(data))
	else:
		push_error("Progress could not be saved: %s" % FileAccess.get_open_error())

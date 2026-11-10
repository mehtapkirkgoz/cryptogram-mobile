extends Node

const CODES = ["tr", "en", "de", "fr", "es"]
var current := "tr"
var catalog: Dictionary = {}

func _ready() -> void:
	for code in CODES:
		catalog[code] = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % code))

func info() -> Dictionary:
	return catalog[current]

func text(key: String) -> String:
	return info().ui.get(key, key)

func puzzles() -> Array:
	return info().puzzles

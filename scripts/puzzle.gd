class_name CipherPuzzle
extends RefCounted

var sentence := ""
var numbers: Dictionary = {}
var answers: Dictionary = {}
var occurrences: Array = []
var guesses: Dictionary = {}
var selected := 0
var hints := 3
var mistakes := 0
var locked: Array = []

func setup(text: String, alphabet: String, saved: Dictionary = {}, starter_hints: int = 0, limit: int = -1) -> void:
	sentence = text
	var random := RandomNumberGenerator.new()
	random.seed = absi(sentence.hash())
	var available_numbers: Array = range(0, 31)
	_shuffle(available_numbers, random)
	for letter in sentence:
		if alphabet.contains(letter) and not numbers.has(letter):
			var code: int = available_numbers.pop_back()
			numbers[letter] = code
			answers[code] = letter
	for letter in sentence:
		if numbers.has(letter):
			occurrences.append({"letter": letter, "code": numbers[letter]})
	for key in saved.get("guesses", {}):
		guesses[int(key)] = saved.guesses[key]
	hints = int(saved.get("hints", 3))
	mistakes = int(saved.get("mistakes", 0))
	for key in saved.get("locked", []):
		locked.append(int(key))
	if starter_hints > 0:
		# Use the same starting clues for new and saved puzzles.
		var codes: Array = answers.keys()
		_shuffle(codes, random)
		var starting_indices: Array = []
		for code in codes.slice(0, mini(starter_hints, codes.size())):
			for index in range(occurrences.size()):
				if occurrences[index].code == code:
					starting_indices.append(index)
					break
		# Keep player guesses, but only three clues are fixed.
		for index in locked.duplicate():
			if not starting_indices.has(index):
				locked.erase(index)
		for index in starting_indices:
			guesses[index] = occurrences[index].letter
			if not locked.has(index):
				locked.append(index)
	select_next()

func guess_for(index: int) -> String:
	return str(guesses.get(index, ""))

func _shuffle(values: Array, random: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index := random.randi_range(0, index)
		var value = values[index]
		values[index] = values[swap_index]
		values[swap_index] = value

func enter(letter: String) -> String:
	if locked.has(selected) or solved():
		return ""
	var code: int = occurrences[selected].code
	guesses[selected] = letter
	if answers.get(code) != letter:
		mistakes += 1
		return "wrong"
	select_next()
	return ""

func select_next() -> void:
	for index in range(occurrences.size()):
		if guesses.get(index, "") != occurrences[index].letter:
			selected = index
			return

func reveal() -> bool:
	if hints <= 0 or solved():
		return false
	if guesses.get(selected, "") == answers[occurrences[selected].code]:
		select_next()
	var code: int = occurrences[selected].code
	guesses[selected] = answers[code]
	locked.append(selected)
	hints -= 1
	select_next()
	return true

func clear_selected() -> void:
	if not locked.has(selected) and not solved():
		guesses.erase(selected)

func ratio() -> float:
	var filled := 0
	for index in range(occurrences.size()):
		if guesses.get(index) == occurrences[index].letter:
			filled += 1
	return float(filled) / maxi(occurrences.size(), 1)

func solved() -> bool:
	return ratio() == 1.0

func occurrence_count() -> int:
	return occurrences.size()

func serialize() -> Dictionary:
	return {"schema": 6, "guesses": guesses, "locked": locked, "hints": hints, "mistakes": mistakes}

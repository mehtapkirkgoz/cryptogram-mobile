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
var mistake_limit := -1
var locked: Array = []

func setup(text: String, alphabet: String, saved: Dictionary = {}, starter_hints: int = 0, limit: int = -1) -> void:
	sentence = text
	for letter in sentence:
		if alphabet.contains(letter) and not numbers.has(letter):
			var code = numbers.size() + 1
			numbers[letter] = code
			answers[code] = letter
	for letter in sentence:
		if numbers.has(letter):
			occurrences.append({"letter": letter, "code": numbers[letter]})
	for key in saved.get("guesses", {}):
		guesses[int(key)] = saved.guesses[key]
	hints = int(saved.get("hints", 3))
	mistakes = int(saved.get("mistakes", 0))
	mistake_limit = int(saved.get("mistake_limit", limit))
	for key in saved.get("locked", []):
		locked.append(int(key))
	if saved.is_empty() and starter_hints > 0:
		var codes: Array = answers.keys()
		codes.sort()
		for code in codes.slice(0, mini(starter_hints, codes.size())):
			for index in range(occurrences.size()):
				if occurrences[index].code == code:
					guesses[index] = answers[code]
					locked.append(index)
					break
	select_next()

func guess_for(index: int) -> String:
	return str(guesses.get(index, ""))

func enter(letter: String) -> String:
	if locked.has(selected) or solved() or game_over():
		return ""
	var code: int = occurrences[selected].code
	if answers.get(code) != letter:
		mistakes += 1
		return "wrong"
	guesses[selected] = letter
	select_next()
	return ""

func game_over() -> bool:
	return mistake_limit > 0 and mistakes >= mistake_limit

func mistakes_left() -> int:
	return -1 if mistake_limit < 0 else maxi(mistake_limit - mistakes, 0)

func select_next() -> void:
	for index in range(occurrences.size()):
		if not guesses.has(index):
			selected = index
			return

func reveal() -> bool:
	if hints <= 0 or solved():
		return false
	if guesses.has(selected):
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
	return {"schema": 4, "guesses": guesses, "locked": locked, "hints": hints, "mistakes": mistakes, "mistake_limit": mistake_limit}

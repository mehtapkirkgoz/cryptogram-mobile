class_name CipherPuzzle
extends RefCounted

var sentence := ""
var numbers: Dictionary = {}
var answers: Dictionary = {}
var guesses: Dictionary = {}
var selected := 1
var hints := 3
var mistakes := 0
var locked: Array = []

func setup(text: String, alphabet: String, saved: Dictionary = {}, starter_hints: int = 0) -> void:
	sentence = text
	for letter in sentence:
		if alphabet.contains(letter) and not numbers.has(letter):
			var code = numbers.size() + 1
			numbers[letter] = code
			answers[code] = letter
	for key in saved.get("guesses", {}):
		guesses[int(key)] = saved.guesses[key]
	hints = int(saved.get("hints", 3))
	mistakes = int(saved.get("mistakes", 0))
	for key in saved.get("locked", []):
		locked.append(int(key))
	if saved.is_empty() and starter_hints > 0:
		var codes: Array = answers.keys()
		codes.sort()
		for code in codes.slice(0, mini(starter_hints, codes.size())):
			guesses[code] = answers[code]
			locked.append(code)
	select_next()

func enter(letter: String) -> String:
	if locked.has(selected) or solved():
		return ""
	for code in guesses:
		if guesses[code] == letter and code != selected:
			return "duplicate"
	if answers.get(selected) != letter:
		mistakes += 1
		return "wrong"
	guesses[selected] = letter
	select_next()
	return ""

func select_next() -> void:
	for code in answers:
		if not guesses.has(code):
			selected = code
			return

func reveal() -> bool:
	if hints <= 0 or solved():
		return false
	if guesses.has(selected):
		select_next()
	guesses[selected] = answers[selected]
	locked.append(selected)
	hints -= 1
	select_next()
	return true

func clear_selected() -> void:
	if not locked.has(selected) and not solved():
		guesses.erase(selected)

func ratio() -> float:
	var total := 0
	var filled := 0
	for letter in sentence:
		if numbers.has(letter):
			total += 1
			if guesses.get(numbers[letter]) == letter:
				filled += 1
	return float(filled) / maxi(total, 1)

func solved() -> bool:
	return ratio() == 1.0

func serialize() -> Dictionary:
	return {"guesses": guesses, "locked": locked, "hints": hints, "mistakes": mistakes}

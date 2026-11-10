extends SceneTree

func _initialize() -> void:
	var puzzle := CipherPuzzle.new()
	puzzle.setup("İYİ BİR GÜN.", "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ")
	assert(puzzle.numbers["İ"] == 1)
	assert(puzzle.enter("A") == "wrong")
	assert(puzzle.mistakes == 1)
	assert(puzzle.guesses.is_empty())
	assert(puzzle.enter("İ") == "")
	assert(is_equal_approx(puzzle.ratio(), 3.0 / 9.0))
	assert(puzzle.enter("İ") == "duplicate")
	assert(puzzle.reveal())
	assert(puzzle.hints == 2)
	var opened: int = puzzle.locked[0]
	puzzle.selected = opened
	puzzle.clear_selected()
	assert(puzzle.guesses.has(opened))
	puzzle.selected = 1
	puzzle.clear_selected()
	assert(not puzzle.guesses.has(1))
	puzzle.enter("İ")
	var restored := CipherPuzzle.new()
	restored.setup(puzzle.sentence, "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ", JSON.parse_string(JSON.stringify(puzzle.serialize())))
	assert(restored.guesses == puzzle.guesses)
	assert(restored.locked == puzzle.locked)
	assert(restored.hints == 2)
	for code in restored.answers:
		restored.selected = code
		restored.enter(restored.answers[code])
	assert(restored.solved())
	for code in ["tr", "en", "de", "fr", "es"]:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % code))
		for entry in data.puzzles:
			var check := CipherPuzzle.new()
			check.setup(entry.text, data.alphabet)
			for character in entry.text:
				assert(character in " .,!?'’" or data.alphabet.contains(character), "Missing character: " + character)
			for answer in check.answers:
				check.selected = answer
				check.enter(check.answers[answer])
			assert(check.solved())
	print("PASS: repeated numbers, Turkish alphabet, mistakes, hints, JSON restore and 15 puzzle solutions")
	quit()

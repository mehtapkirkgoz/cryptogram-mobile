extends SceneTree

func _initialize() -> void:
	var puzzle := CipherPuzzle.new()
	puzzle.setup("ABBA C", "ABCDE")
	assert(puzzle.numbers["A"] >= 0 and puzzle.numbers["A"] <= 30)
	assert(puzzle.numbers["A"] != puzzle.numbers["B"])
	assert(puzzle.occurrence_count() == 5)
	assert(puzzle.enter("Z") == "wrong")
	assert(puzzle.mistakes == 1)
	assert(puzzle.guess_for(0) == "Z", "Wrong guesses must remain visible")
	assert(puzzle.enter("A") == "")
	assert(puzzle.guess_for(0) == "A")
	assert(puzzle.guess_for(2).is_empty(), "Repeated letters are independent cells")
	puzzle.selected = 2
	assert(puzzle.enter("B") == "")
	assert(puzzle.guess_for(1).is_empty())
	assert(puzzle.guess_for(2) == "B")
	puzzle.selected = 3
	assert(puzzle.reveal())
	assert(puzzle.guess_for(3) == "A")
	assert(puzzle.hints == 2)
	puzzle.selected = 3
	puzzle.clear_selected()
	assert(puzzle.guess_for(3) == "A", "Revealed letters are protected")
	var restored := CipherPuzzle.new()
	restored.setup(puzzle.sentence, "ABCDE", JSON.parse_string(JSON.stringify(puzzle.serialize())))
	assert(restored.guesses == puzzle.guesses)
	assert(restored.locked == puzzle.locked)
	for index in range(restored.occurrence_count()):
		restored.selected = index
		restored.enter(restored.occurrences[index].letter)
	assert(restored.solved())

	# Each new and resumed level starts with four distinct, locked letter types.
	for code in ["tr", "en", "de", "fr", "es"]:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % code))
		for entry in data.puzzles:
			var check := CipherPuzzle.new()
			check.setup(entry.text, data.alphabet, {}, 4)
			var distinct := {}
			for index in check.starting_clues:
				assert(check.locked.has(index))
				assert(check.guess_for(index) == check.occurrences[index].letter)
				distinct[check.occurrences[index].letter] = true
			assert(distinct.size() == mini(4, check.answers.size()), "Starting clues must use different letters")
			var resumed := CipherPuzzle.new()
			resumed.setup(entry.text, data.alphabet, JSON.parse_string(JSON.stringify(check.serialize())), 4)
			assert(resumed.starting_clues == check.starting_clues)
			assert(resumed.locked == check.locked)
			for index in range(check.occurrence_count()):
				resumed.selected = index
				resumed.enter(resumed.occurrences[index].letter)
			assert(resumed.solved())
	print("PASS: wrong guesses, independent cells, reveal, four unique clues, persistence and multilingual puzzles")
	quit()

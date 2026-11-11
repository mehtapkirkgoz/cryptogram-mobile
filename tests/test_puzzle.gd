extends SceneTree

func _initialize() -> void:
	var puzzle := CipherPuzzle.new()
	puzzle.setup("ABBA C", "ABCDE")
	assert(puzzle.numbers["A"] >= 1 and puzzle.numbers["A"] <= 50)
	assert(puzzle.numbers["A"] != puzzle.numbers["B"])
	assert(puzzle.occurrence_count() == 5)
	assert(puzzle.enter("Z") == "wrong")
	assert(puzzle.mistakes == 1)
	assert(puzzle.enter("A") == "")
	assert(puzzle.guess_for(0) == "A")
	assert(puzzle.guess_for(2).is_empty())
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
	assert(puzzle.guess_for(3) == "A")
	var restored := CipherPuzzle.new()
	restored.setup(puzzle.sentence, "ABCDE", JSON.parse_string(JSON.stringify(puzzle.serialize())))
	assert(restored.guesses == puzzle.guesses)
	assert(restored.locked == puzzle.locked)
	for index in range(restored.occurrence_count()):
		restored.selected = index
		restored.enter(restored.occurrences[index].letter)
	assert(restored.solved())
	var limited := CipherPuzzle.new()
	limited.setup("AB", "AB", {}, 0, 3)
	limited.selected = 0
	limited.enter("B")
	limited.selected = 0
	limited.enter("B")
	limited.selected = 0
	limited.enter("B")
	assert(limited.game_over())
	assert(limited.mistakes_left() == 0)
	for code in ["tr", "en", "de", "fr", "es"]:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % code))
		for entry in data.puzzles:
			var check := CipherPuzzle.new()
			check.setup(entry.text, data.alphabet)
			for index in range(check.occurrence_count()):
				check.selected = index
				check.enter(check.occurrences[index].letter)
			assert(check.solved())
	print("PASS: independent repeated-number cells, reveal, persistence and 30 puzzle solutions")
	quit()

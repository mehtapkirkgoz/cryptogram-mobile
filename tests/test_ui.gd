extends Node

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	var root := get_tree().root
	root.add_child(app)
	Progress.state().sessions.clear()
	var original_language: String = Languages.current
	for code in Languages.CODES:
		assert(Languages.puzzles().size() == 100)
		Languages.current = code
		app.home()
		await get_tree().process_frame
		await get_tree().process_frame
		assert(app.body.get_combined_minimum_size().x <= 440, "Home overflow: " + code)
		if "--capture" in OS.get_cmdline_user_args() and code == "tr":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("cryptogram-home.png"))
		for index in range(Languages.puzzles().size()):
			app.start(index)
			await get_tree().process_frame
			await get_tree().process_frame
			assert(app.body.get_combined_minimum_size().x <= 440, "Puzzle overflow: " + code)
			if index == 1:
				var selected_before: int = app.game.selected
				var expected: String = app.game.occurrences[selected_before].letter
				var key_button: Button
				for node in app.find_children("*", "Button", true, false):
					if node.text == expected:
						key_button = node
						break
				assert(key_button != null, "Keyboard key not found: " + expected)
				key_button.emit_signal("pressed")
				await get_tree().process_frame
				assert(app.game.guesses.has(selected_before), "Correct keyboard key was not accepted")
				var mistakes_before: int = app.game.mistakes
				var wrong_button: Button
				for node in app.find_children("*", "Button", true, false):
					if node.text.length() == 1 and Languages.info().keyboard.any(func(row): return node.text in row) and node.text != app.game.occurrences[app.game.selected].letter:
						wrong_button = node
						break
				assert(wrong_button != null)
				wrong_button.emit_signal("pressed")
				await get_tree().process_frame
				assert(app.game.mistakes == mistakes_before + 1, "Wrong key did not increment mistakes")
		if "--capture" in OS.get_cmdline_user_args() and code == "tr":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("cryptogram-puzzle.png"))
		for occurrence_index in range(app.game.occurrence_count()):
			app.game.selected = occurrence_index
			app.game.enter(app.game.occurrences[occurrence_index].letter)
		app.show_game()
		await get_tree().process_frame
		assert(app.game.solved())
		app.start_daily()
		await get_tree().process_frame
		assert(app.daily)
		app.levels()
		await get_tree().process_frame
		app.stats()
		await get_tree().process_frame
		app.settings()
		await get_tree().process_frame
	Languages.current = original_language
	print("PASS: home, 500 puzzle screens, levels, statistics and settings in five languages")
	get_tree().quit()

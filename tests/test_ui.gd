extends Node

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	var root := get_tree().root
	root.add_child(app)
	var original_language: String = Languages.current
	for code in Languages.CODES:
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
	print("PASS: home, 30 puzzle screens, levels, statistics and settings in five languages")
	get_tree().quit()

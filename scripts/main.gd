extends Control

const INK = Color("19283f")
const BLUE = Color("477fba")
const MUTED = Color("78849a")
const PALE = Color("e6effb")
var body: VBoxContainer
var game: CipherPuzzle
var puzzle_index := 0
var session_key := ""
var daily := false
var message := ""
var screen := "home"

func _ready() -> void:
	var skin := Theme.new()
	skin.default_font_size = 18
	skin.set_color("font_color", "Label", INK)
	skin.set_color("font_color", "Button", INK)
	skin.set_color("font_hover_color", "Button", BLUE)
	skin.set_color("font_pressed_color", "Button", BLUE)
	skin.set_stylebox("normal", "Button", box(Color("fcfcff")))
	skin.set_stylebox("hover", "Button", box(PALE, BLUE))
	skin.set_stylebox("pressed", "Button", box(Color("d4e5fa"), BLUE))
	skin.set_stylebox("focus", "Button", box(Color.TRANSPARENT, BLUE))
	skin.set_constant("h_separation", "HBoxContainer", 8)
	skin.set_constant("v_separation", "VBoxContainer", 12)
	theme = skin
	home()

func box(color: Color, border: Color = Color("dfe4ee")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(14)
	style.shadow_color = Color(0.1, 0.2, 0.35, 0.07)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 3)
	return style

func base() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	scroll.add_child(margin)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	margin.add_child(body)

func label_at(parent: Node, text: String, size: int = 18, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func button_at(parent: Node, text: String, callback: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 54
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 17)
	if primary:
		button.add_theme_stylebox_override("normal", box(BLUE, BLUE))
		button.add_theme_color_override("font_color", Color.WHITE)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func panel(parent: Node) -> VBoxContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", box(Color("fcfcff")))
	parent.add_child(card)
	var column := VBoxContainer.new()
	card.add_child(column)
	return column

func row(parent: Node) -> HBoxContainer:
	var result := HBoxContainer.new()
	parent.add_child(result)
	return result

func tr_text(key: String) -> String:
	return Languages.text(key)

func home() -> void:
	screen = "home"
	base()
	var top := row(body)
	label_at(top, "C R Y P T O G R A M", 13, MUTED)
	button_at(top, "⚙", settings).size_flags_horizontal = Control.SIZE_SHRINK_END
	var emblem := TextureRect.new()
	emblem.texture = preload("res://assets/mark.svg")
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	emblem.custom_minimum_size.y = 170
	body.add_child(emblem)
	label_at(body, "Cryptogram", 46)
	label_at(body, tr_text("tagline"), 20, MUTED)
	var completed: Array = Progress.state().completed
	var index := mini(completed.size(), Languages.puzzles().size() - 1)
	button_at(body, "▶   " + tr_text("play"), func(): start(index), true).custom_minimum_size.y = 70
	var shortcuts := row(body)
	button_at(shortcuts, "▦\n" + tr_text("daily"), start_daily)
	button_at(shortcuts, "◇\n" + tr_text("levels"), levels)
	button_at(shortcuts, "▥\n" + tr_text("stats"), stats)
	var language_card := panel(body)
	label_at(language_card, tr_text("language"), 22)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	language_card.add_child(grid)
	for code in Languages.CODES:
		var caption: String = Languages.catalog[code].name
		if code == Languages.current:
			caption = "✓ " + caption
		button_at(grid, caption, func(): change_language(code), code == Languages.current)
	label_at(body, "%s  %d / %d" % [tr_text("completed"), completed.size(), Languages.puzzles().size()], 15, MUTED)

func change_language(code: String) -> void:
	Languages.current = code
	Progress.save()
	home()

func header(title: String) -> void:
	var line := row(body)
	button_at(line, "‹", home).size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label_at(line, title, 25)

func levels() -> void:
	screen = "levels"
	base()
	header(tr_text("levels"))
	for i in range(Languages.puzzles().size()):
		var done: bool = Progress.state().completed.has(Languages.puzzles()[i].id)
		var unlocked: bool = i == 0 or Progress.state().completed.has(Languages.puzzles()[i - 1].id)
		var caption := "%02d   %s   %s" % [i + 1, Languages.puzzles()[i].topic, "✓" if done else ""]
		var button := button_at(body, caption if unlocked else caption + " · " + tr_text("locked"), func(): start(i))
		button.disabled = not unlocked

func stats() -> void:
	screen = "stats"
	base()
	header(tr_text("stats"))
	label_at(body, Languages.info().name, 20, BLUE)
	var card := panel(body)
	label_at(card, str(Progress.state().completed.size()), 60, BLUE)
	label_at(card, tr_text("completed"), 22)
	label_at(card, "%s: %d" % [tr_text("mistakes"), Progress.state().mistakes], 20, MUTED)

func settings() -> void:
	screen = "settings"
	base()
	header(tr_text("settings"))
	label_at(body, tr_text("language"), 22)
	for code in Languages.CODES:
		button_at(body, Languages.catalog[code].name, func(): change_language(code), code == Languages.current)
	label_at(body, "Cryptogram · 0.1.0", 15, MUTED)

func start_daily() -> void:
	var today := Time.get_date_string_from_system()
	start(int(today.replace("-", "")) % Languages.puzzles().size(), true)

func start(index: int, is_daily: bool = false) -> void:
	daily = is_daily
	puzzle_index = index
	var puzzle: Dictionary = Languages.puzzles()[index]
	session_key = "daily_" + Time.get_date_string_from_system() if daily else puzzle.id
	game = CipherPuzzle.new()
	game.setup(puzzle.text, Languages.info().alphabet, Progress.state().sessions.get(session_key, {}), starter_hints(index))
	message = tr_text("instruction")
	show_game()

func starter_hints(index: int) -> int:
	if daily:
		return 1
	return [2, 1, 0][mini(index, 2)]

func difficulty(index: int) -> String:
	return [tr_text("easy"), "Orta", "Zor"][mini(index, 2)]

func persist() -> void:
	Progress.state().sessions[session_key] = game.serialize()
	if game.solved() and not daily:
		var id: String = Languages.puzzles()[puzzle_index].id
		if not Progress.state().completed.has(id):
			Progress.state().completed.append(id)
	Progress.save()

func show_game() -> void:
	screen = "game"
	base()
	header(tr_text("daily") if daily else "%s %d" % [tr_text("puzzle"), puzzle_index + 1])
	var info := panel(body)
	label_at(info, "%s  ·  %s  ·  %d%%" % [difficulty(puzzle_index), Languages.info().name, roundi(game.ratio() * 100)], 17)
	var progress_bar := ProgressBar.new()
	progress_bar.value = game.ratio() * 100
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size.y = 8
	var track := box(PALE, PALE)
	track.set_content_margin_all(0)
	var fill := box(BLUE, BLUE)
	fill.set_content_margin_all(0)
	progress_bar.add_theme_stylebox_override("background", track)
	progress_bar.add_theme_stylebox_override("fill", fill)
	info.add_child(progress_bar)
	var board := panel(body)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 16)
	flow.add_theme_constant_override("v_separation", 20)
	board.add_child(flow)
	var word_index := 0
	for word in game.sentence.split(" "):
		var word_margin := MarginContainer.new()
		word_margin.add_theme_constant_override("margin_left", 5 if word_index > 0 else 0)
		word_margin.add_theme_constant_override("margin_right", 5)
		flow.add_child(word_margin)
		var letters := HBoxContainer.new()
		letters.add_theme_constant_override("separation", 2)
		word_margin.add_child(letters)
		for letter in word:
			if not game.numbers.has(letter):
				var punctuation := label_at(letters, letter, 22)
				punctuation.custom_minimum_size.x = 10
				continue
			var code: int = game.numbers[letter]
			var cell := Button.new()
			cell.text = "%d\n%s" % [code, game.guesses.get(code, "_")]
			cell.custom_minimum_size = Vector2(29, 64)
			cell.add_theme_font_size_override("font_size", 18)
			var style := box(PALE if code == game.selected else Color("f4f6fb"), BLUE if code == game.selected else Color("e0e6f0"))
			style.set_content_margin_all(2)
			style.set_corner_radius_all(7)
			cell.add_theme_stylebox_override("normal", style)
			cell.pressed.connect(func(): game.selected = code; show_game())
			letters.add_child(cell)
		word_index += 1
	label_at(body, message if not game.solved() else tr_text("daily_won") if daily else tr_text("won"), 16, BLUE)
	if game.solved():
		if not daily and puzzle_index + 1 < Languages.puzzles().size():
			button_at(body, tr_text("next"), func(): start(puzzle_index + 1), true)
		button_at(body, tr_text("home"), home)
		return
	var actions := row(body)
	button_at(actions, "%s · %d" % [tr_text("reveal"), game.hints], reveal)
	button_at(actions, tr_text("hint"), hint, true)
	button_at(actions, tr_text("clear"), clear_letter)
	for keys in Languages.info().keyboard:
		var key_row := row(body)
		key_row.add_theme_constant_override("separation", 3)
		for letter in keys:
			var key := button_at(key_row, letter, func(): enter(letter))
			key.custom_minimum_size = Vector2(0, 46)
			key.add_theme_font_size_override("font_size", 16)
			for state in ["normal", "hover", "pressed", "focus"]:
				var style := box(Color("fcfcff"))
				style.set_content_margin_all(1)
				style.set_corner_radius_all(7)
				key.add_theme_stylebox_override(state, style)
	label_at(body, "%s: %d" % [tr_text("mistakes"), game.mistakes], 15, MUTED)

func enter(letter: String) -> void:
	var previous := game.mistakes
	var result := game.enter(letter)
	Progress.state().mistakes += game.mistakes - previous
	message = tr_text(result) if not result.is_empty() else tr_text("instruction")
	persist()
	show_game()

func reveal() -> void:
	message = tr_text("instruction") if game.reveal() else tr_text("no_hints")
	persist()
	show_game()

func hint() -> void:
	message = "%s: %s" % [tr_text("topic"), Languages.puzzles()[puzzle_index].topic]
	show_game()

func clear_letter() -> void:
	game.clear_selected()
	message = tr_text("cleared")
	persist()
	show_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		Progress.save()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		home()

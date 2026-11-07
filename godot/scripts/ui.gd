extends Control
## Minimal noir HUD: amber bullet-time meter, health bar, ammo counter,
## crosshair, bullet-time color filter, vignette, win/lose text.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var main := get_node("/root/Main")
	var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
	var size := get_size()

	# bullet-time color filter
	if BulletTime.world_scale < 0.9:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.15, 0.22, 0.35, (1.0 - BulletTime.world_scale) * 0.18))

	# vignette: nested outline strips, darkest at the screen edge
	for i in range(8):
		var m := i * 16.0
		draw_rect(Rect2(Vector2(m, m * 0.56), size - Vector2(m * 2.0, m * 1.12)),
			Color(0, 0, 0, 0.14 - i * 0.017), false, 16.0)

	if player == null:
		return

	# crosshair
	var cx := size.x / 2.0
	var cy := size.y / 2.0
	for seg in [[Vector2(cx - 7, cy), Vector2(cx - 2, cy)], [Vector2(cx + 2, cy), Vector2(cx + 7, cy)],
			[Vector2(cx, cy - 7), Vector2(cx, cy - 2)], [Vector2(cx, cy + 2), Vector2(cx, cy + 7)]]:
		draw_line(seg[0], seg[1], Color(0.9, 0.9, 0.9, 0.8), 1.0)

	# HUD panel
	var panel := Rect2(Vector2(12, size.y - 46), Vector2(210, 34))
	draw_rect(panel, Color(0.04, 0.05, 0.08, 0.7))
	draw_rect(panel, Color(0.7, 0.65, 0.5, 0.4), false, 1.0)

	# bullet-time meter (amber)
	draw_rect(Rect2(Vector2(16, size.y - 42), Vector2(150, 7)), Color(0.23, 0.18, 0.08))
	draw_rect(Rect2(Vector2(16, size.y - 42), Vector2(150.0 * BulletTime.meter, 7)), Color(0.91, 0.63, 0.13))

	# health
	draw_rect(Rect2(Vector2(16, size.y - 31), Vector2(150, 7)), Color(0.18, 0.08, 0.08))
	draw_rect(Rect2(Vector2(16, size.y - 31), Vector2(150.0 * maxf(0.0, player.hp) / player.max_hp, 7)), Color(0.75, 0.28, 0.28))

	# ammo
	var font := get_theme_default_font()
	var fs := get_theme_default_font_size()
	var ammo_text := "RELOADING" if player.reloading > 0.0 else str(int(player.ammo))
	draw_string(font, Vector2(174, size.y - 26), ammo_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, fs + 4, Color(0.87, 0.86, 0.8))

	# state text
	if main.state != "playing":
		var msg := "THE ROOM IS QUIET" if main.state == "win" else "DEAD HOUR"
		draw_string(font, Vector2(cx - 160.0, cy - 10.0), msg, HORIZONTAL_ALIGNMENT_CENTER, 320.0, fs * 2, Color(0.91, 0.86, 0.75))
		draw_string(font, Vector2(cx - 160.0, cy + 30.0), "Press Enter to restart", HORIZONTAL_ALIGNMENT_CENTER, 320.0, fs, Color(0.85, 0.85, 0.85, 0.7))

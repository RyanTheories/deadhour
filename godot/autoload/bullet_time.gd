extends Node
## DEADHOUR bullet-time system (autoload "BulletTime").
## World runs at WORLD scale, the player keeps a deliberate edge at PLAYER scale.
## Each entity scales its own updates; Engine.time_scale stays at 1.

signal changed(active: bool)

const WORLD := 0.25
const PLAYER := 0.4
const DRAIN := 0.28
const REGEN := 0.045

var meter := 1.0
var active := false
var world_scale := 1.0
var player_scale := 1.0

func _process(delta: float) -> void:
	var want := (Input.is_key_pressed(KEY_Q) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)) and meter > 0.0
	if want != active:
		active = want
		changed.emit(active)
	var tw := WORLD if active else 1.0
	var tp := PLAYER if active else 1.0
	world_scale = lerpf(world_scale, tw, delta * 8.0)
	player_scale = lerpf(player_scale, tp, delta * 8.0)
	if active:
		meter = maxf(0.0, meter - DRAIN * delta)
	else:
		meter = minf(1.0, meter + REGEN * delta)

func refill(amount: float) -> void:
	meter = minf(1.0, meter + amount)

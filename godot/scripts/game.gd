extends Node3D
## Main scene: builds the apartment-lobby level, spawns player/enemies/pickups,
## owns tracers, rain, and win/lose state. Everything is built in code so the
## project stays a handful of small files.

const FLOOR_HALF := 14.0
const WALL_H := 4.0
const WALL_T := 0.5

var player: CharacterBody3D
var state := "playing"
var pickups: Array[Area3D] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_level()
	_spawn_player()
	_spawn_enemies()
	_spawn_pickups()
	_spawn_rain()
	_spawn_ui()

func set_state(s: String) -> void:
	if state == "playing":
		state = s
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	if state == "playing" and get_tree().get_nodes_in_group("enemies").is_empty():
		set_state("win")
	if state != "playing" and Input.is_key_pressed(KEY_ENTER):
		get_tree().reload_current_scene()

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ---------- Level ----------

func _box(pos: Vector3, size: Vector3, color: Color, is_wall: bool = false) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mesh.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	body.add_child(mesh)
	body.position = pos
	if is_wall:
		body.add_to_group("walls")
	add_child(body)

func _build_level() -> void:
	# floor
	var floor_mesh := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(FLOOR_HALF * 2.0, FLOOR_HALF * 2.0)
	floor_mesh.mesh = pm
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.05, 0.06, 0.09)
	fmat.roughness = 0.4  # wet sheen under lights
	floor_mesh.material_override = fmat
	floor_mesh.rotation.x = 0.0
	add_child(floor_mesh)
	var floor_col := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = WorldBoundaryShape3D.new()
	floor_col.add_child(cs)
	add_child(floor_col)

	# walls
	var dark := Color(0.06, 0.07, 0.1)
	_box(Vector3(0, WALL_H / 2.0, -FLOOR_HALF), Vector3(FLOOR_HALF * 2.0, WALL_H, WALL_T), dark, true)
	_box(Vector3(0, WALL_H / 2.0, FLOOR_HALF), Vector3(FLOOR_HALF * 2.0, WALL_H, WALL_T), dark, true)
	_box(Vector3(-FLOOR_HALF, WALL_H / 2.0, 0), Vector3(WALL_T, WALL_H, FLOOR_HALF * 2.0), dark, true)
	_box(Vector3(FLOOR_HALF, WALL_H / 2.0, 0), Vector3(WALL_T, WALL_H, FLOOR_HALF * 2.0), dark, true)
	# pillars
	_box(Vector3(-6, WALL_H / 2.0, -6), Vector3(0.8, WALL_H, 0.8), dark, true)
	_box(Vector3(6, WALL_H / 2.0, -6), Vector3(0.8, WALL_H, 0.8), dark, true)
	_box(Vector3(-6, WALL_H / 2.0, 6), Vector3(0.8, WALL_H, 0.8), dark, true)
	_box(Vector3(6, WALL_H / 2.0, 6), Vector3(0.8, WALL_H, 0.8), dark, true)
	# crates / cover
	var crate := Color(0.13, 0.11, 0.08)
	for c in [Vector3(-3, 0.5, -3), Vector3(3, 0.5, -3), Vector3(-3, 0.5, 3), Vector3(3, 0.5, 3)]:
		_box(c, Vector3(1.2, 1.0, 1.2), crate, true)
	# overturned sofa
	_box(Vector3(0, 0.45, 0), Vector3(2.4, 0.9, 0.9), Color(0.1, 0.08, 0.09), true)

	# environment: near-black ambient, sodium lamp + cyan neon spill
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.04, 0.05, 0.09)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.05, 0.06, 0.1)
	env.fog_density = 0.02
	world_env.environment = env
	add_child(world_env)

	var lamp := SpotLight3D.new()
	lamp.position = Vector3(0, 3.8, 0)
	lamp.light_color = Color(1.0, 0.72, 0.4)
	lamp.light_energy = 4.0
	lamp.spot_range = 18.0
	lamp.spot_angle = 55.0
	lamp.shadow_enabled = true
	add_child(lamp)
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.06
	pole_mesh.bottom_radius = 0.06
	pole_mesh.height = 4.0
	pole.mesh = pole_mesh
	pole.position = Vector3(0, 2.0, 0.0)
	add_child(pole)

	var neon := OmniLight3D.new()
	neon.position = Vector3(-FLOOR_HALF + 1.5, 2.0, 0)
	neon.light_color = Color(0.4, 0.85, 1.0)
	neon.light_energy = 1.5
	neon.omni_range = 9.0
	add_child(neon)
	var neon2 := OmniLight3D.new()
	neon2.position = Vector3(FLOOR_HALF - 1.5, 2.0, 0)
	neon2.light_color = Color(1.0, 0.55, 0.25)
	neon2.light_energy = 1.5
	neon2.omni_range = 9.0
	add_child(neon2)

# ---------- Spawns ----------

func _spawn_player() -> void:
	var script := preload("res://scripts/player.gd")
	player = script.new()
	player.position = Vector3(-11, 1.1, 0)
	add_child(player)

func _spawn_enemies() -> void:
	var script := preload("res://scripts/enemy.gd")
	for pos in [Vector3(8, 1.1, -8), Vector3(10, 1.1, 8), Vector3(0, 1.1, -10), Vector3(6, 1.1, 0)]:
		var e := script.new()
		e.position = pos
		add_child(e)

func _spawn_pickups() -> void:
	for pos in [Vector3(0, 0.4, 9), Vector3(11, 0.4, -4)]:
		var a := Area3D.new()
		var cs := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.8
		cs.shape = sphere
		a.add_child(cs)
		var mesh := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.25, 0.4, 0.25)
		mesh.mesh = bm
		mesh.position.y = 0.2
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.9, 0.9, 0.9)
		mat.emission_enabled = true
		mat.emission = Color(0.8, 0.85, 0.9)
		mat.emission_energy_multiplier = 0.8
		mesh.material_override = mat
		a.add_child(mesh)
		a.body_entered.connect(_on_pickup.bind(a))
		a.position = pos
		add_child(a)
		pickups.append(a)

func _on_pickup(body: Node, pickup: Area3D) -> void:
	if body == player and state == "playing":
		player.hp = minf(player.max_hp, player.hp + 50.0)
		pickup.queue_free()

func _spawn_ui() -> void:
	var layer := CanvasLayer.new()
	var ui := Control.new()
	ui.set_script(preload("res://scripts/ui.gd"))
	layer.add_child(ui)
	add_child(layer)

func _spawn_rain() -> void:
	var rain := CPUParticles3D.new()
	rain.amount = 600
	rain.lifetime = 1.5
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = Vector3(FLOOR_HALF, 0.2, FLOOR_HALF)
	rain.direction = Vector3(0.15, -1, 0.05)
	rain.spread = 2.0
	rain.initial_velocity = 30.0
	rain.gravity = Vector3.ZERO
	rain.scale_amount_min = 0.5
	rain.scale_amount_max = 1.0
	var streak := BoxMesh.new()
	streak.size = Vector3(0.015, 0.7, 0.015)
	rain.draw_pass_mesh = streak
	rain.position = Vector3(0, 6.0, 0)
	add_child(rain)

# ---------- Tracers ----------

func spawn_tracer(from: Vector3, to: Vector3, friendly: bool) -> void:
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.02, 0.02, from.distance_to(to))
	mesh.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.9, 0.7)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.7) if friendly else Color(1.0, 0.5, 0.4)
	mat.emission_energy_multiplier = 1.5
	mesh.material_override = mat
	mesh.look_at_from_position((from + to) / 2.0, to, Vector3.UP)
	add_child(mesh)
	var t := Timer.new()
	t.wait_time = 0.06
	t.one_shot = true
	t.timeout.connect(mesh.queue_free)
	add_child(t)
	t.start()

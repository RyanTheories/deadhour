extends CharacterBody3D
## Third-person player. Builds its own body/camera children so the scene
## stays a single minimal .tscn. Movement runs on BulletTime.player_scale so
## bullet time gives the player a deliberate edge over the world.

const SPEED := 8.0
const GRAVITY := 22.0
const FIRE_RATE := 0.22
const RELOAD_TIME := 1.1
const MAG := 12
const DIVE_SPEED := 16.0
const DIVE_TIME := 0.35

var hp := 100.0
var max_hp := 100.0
var ammo := MAG
var fire_cd := 0.0
var reloading := 0.0
var diving := false
var dive_t := 0.0
var dive_dir := Vector3.ZERO
var yaw := 0.0
var pitch := 0.0

var camera: Camera3D

func _ready() -> void:
	add_to_group("player")
	var shape := CapsuleShape3D.new()
	shape.height = 1.8
	shape.radius = 0.35
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position.y = 0.9
	add_child(col)

	var mesh := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.height = 1.8
	cap.radius = 0.35
	mesh.mesh = cap
	mesh.position.y = 0.9
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.03, 0.04, 0.06)
	mesh.material_override = mat
	add_child(mesh)

	var boom := Node3D.new()
	boom.name = "Boom"
	boom.position.y = 1.6
	add_child(boom)
	var cam := Camera3D.new()
	cam.name = "Camera"
	cam.fov = 65.0
	cam.position = Vector3(0.7, 0.4, 3.0)
	boom.add_child(cam)
	camera = cam

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * 0.0022
		pitch = clampf(pitch - event.relative.y * 0.0022, -1.2, 1.2)
		rotation.y = yaw
		$Boom.rotation.x = pitch
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()

func _physics_process(delta: float) -> void:
	var dt := delta * BulletTime.player_scale
	fire_cd = maxf(0.0, fire_cd - dt)
	if reloading > 0.0:
		reloading -= dt
		if reloading <= 0.0:
			ammo = MAG

	var input := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input.z -= 1.0
	if Input.is_key_pressed(KEY_S): input.z += 1.0
	if Input.is_key_pressed(KEY_A): input.x -= 1.0
	if Input.is_key_pressed(KEY_D): input.x += 1.0
	input = input.rotated(Vector3.UP, yaw).normalized() if input.length() > 0.0 else Vector3.ZERO

	if Input.is_key_pressed(KEY_SPACE) and not diving:
		diving = true
		dive_t = DIVE_TIME
		dive_dir = input if input.length() > 0.0 else -global_transform.basis.z
	if Input.is_key_pressed(KEY_R):
		try_reload()

	if diving:
		dive_t -= dt
		velocity.x = dive_dir.x * DIVE_SPEED
		velocity.z = dive_dir.z * DIVE_SPEED
		if dive_t <= 0.0:
			diving = false
	else:
		velocity.x = input.x * SPEED
		velocity.z = input.z * SPEED
	velocity.y -= GRAVITY * dt
	move_and_slide()

func try_reload() -> void:
	if reloading <= 0.0 and ammo < MAG:
		reloading = RELOAD_TIME

func shoot() -> void:
	if fire_cd > 0.0 or reloading > 0.0 or ammo <= 0.0:
		return
	fire_cd = FIRE_RATE
	ammo -= 1.0
	if ammo == 0.0:
		try_reload()
	var from := camera.global_position
	var dir := -camera.global_transform.basis.z
	var params := PhysicsRayQueryParameters3D.create(from, from + dir * 60.0)
	params.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	var to: Vector3 = hit.position if hit else from + dir * 60.0
	get_parent().spawn_tracer($Boom.global_position - dir * 0.6, to, true)
	if hit and hit.collider.is_in_group("enemies"):
		hit.collider.take_damage(34.0)

func take_damage(dmg: float) -> void:
	hp -= dmg
	if hp <= 0.0:
		get_parent().set_state("lose")

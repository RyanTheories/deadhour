extends CharacterBody3D
## PoC mobster: advance toward the player, strafe when close, shoot on a timer.
## Runs on BulletTime.world_scale so bullet time slows the world, not the player.

const SPEED := 4.5
const GRAVITY := 22.0
const FIRE_DELAY_MIN := 1.2
const FIRE_DELAY_MAX := 2.0

var hp := 40.0
var fire_cd := 1.5
var strafe_dir := 1.0
var player: Node3D

func _ready() -> void:
	add_to_group("enemies")
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
	mat.albedo_color = Color(0.05, 0.06, 0.08)
	mesh.material_override = mat
	add_child(mesh)

	# red tie accent for readability in the dark
	var tie := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.08, 0.5, 0.02)
	tie.mesh = box
	tie.position = Vector3(0, 1.15, -0.36)
	var tie_mat := StandardMaterial3D.new()
	tie_mat.albedo_color = Color(0.85, 0.15, 0.2)
	tie_mat.emission_enabled = true
	tie_mat.emission = Color(0.85, 0.15, 0.2)
	tie_mat.emission_energy_multiplier = 0.6
	tie.material_override = tie_mat
	add_child(tie)

func _physics_process(delta: float) -> void:
	if hp <= 0.0:
		return
	var dt := delta * BulletTime.world_scale
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	var to_p: Vector3 = player.global_position - global_position
	to_p.y = 0.0
	var dist := to_p.length()
	var dir := to_p / maxf(dist, 0.001)

	var move := Vector3.ZERO
	if dist > 6.0:
		move = dir * SPEED
	else:
		var perp := Vector3(-dir.z, 0.0, dir.x) * strafe_dir
		move = perp * SPEED * 0.5
	velocity.x = move.x
	velocity.z = move.z
	velocity.y -= GRAVITY * dt
	move_and_slide()
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	fire_cd -= dt
	if fire_cd <= 0.0 and dist < 25.0:
		fire_cd = randf_range(FIRE_DELAY_MIN, FIRE_DELAY_MAX)
		shoot()

func shoot() -> void:
	var from := global_position + Vector3(0, 1.4, 0) - global_transform.basis.z * 0.5
	var target: Vector3 = player.global_position + Vector3(0, 1.2, 0)
	target += Vector3(randf_range(-0.8, 0.8), randf_range(-0.4, 0.4), randf_range(-0.8, 0.8))
	var params := PhysicsRayQueryParameters3D.create(from, target)
	params.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(params)
	var to: Vector3 = hit.position if hit else target
	get_parent().spawn_tracer(from, to, false)
	if hit and hit.collider.is_in_group("player"):
		hit.collider.take_damage(16.0)

func take_damage(dmg: float) -> void:
	hp -= dmg
	if hp <= 0.0:
		BulletTime.refill(0.35)
		queue_free()

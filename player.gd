class_name Player extends CharacterBody3D

@export var player_name: String = "Anon"
@export var name_plate: Label
@export var mouse_sensitivity: float = 0.002
@export var body: MeshInstance3D

@export var player_color: Color = Color.WHITE:
	set = set_player_color

@onready var cam: Camera3D = $Camera3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5



func _enter_tree() -> void:
	randomize()
	set_multiplayer_authority(name.to_int())
	name_plate.text = player_name + " " + str(name)

#	if is_multiplayer_authority():
#		player_color = Color.from_hsv(randi() % 360 / 360.0, 0.8, 1.0)



func _ready() -> void:
	_apply_color()

	if not is_multiplayer_authority():
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.current = true



func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(90), deg_to_rad(90))



func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()



# ---- COLOR HANDLING ----
func _apply_color() -> void:
	if not body:
		return
		
	var mat = StandardMaterial3D.new()
	mat.albedo_color = player_color
	body.set_surface_override_material(0, mat)




func set_player_color(new_color: Color) -> void:
	player_color = new_color
	_apply_color()

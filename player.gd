class_name Player extends CharacterBody3D

@export var mouse_sensitivity:float = 0.002

@onready var cam: Camera3D = $Camera3D

const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())



func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.current = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	# give us back the cursor when esc is pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

	if event is InputEventMouseMotion:
		# rotate self left and right
		rotate_y(-event.relative.x * mouse_sensitivity)

		# rotate camera up and down
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(90), deg_to_rad(90))
		

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

extends KinematicBody

const MOUSE_SENSITIVITY = 0.1

onready var camera = $CamRoot/Camera
onready var weapon_manager = $CamRoot/Weapons

# Movement
var velocity = Vector3.ZERO
var current_vel = Vector3.ZERO
var dir = Vector3.ZERO

const SPEED = 10
const SPRINT_SPEED = 20
const ACCEL = 15.0

# Jump
const GRAVITY = -40.0
const JUMP_SPEED = 15
var jump_counter = 0
const AIR_ACCEL = 9.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _process(delta):
	window_activity()



func _physics_process(delta):
	
	process_movement_inputs()
	process_weapons()
	process_jump(delta)
	process_movement(delta)




func process_movement_inputs():
	# Get the input directions
	dir = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir -= camera.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += camera.global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += camera.global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= camera.global_transform.basis.x
	
	# Normalizing the input directions
	dir = dir.normalized()

func process_jump(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		jump_counter = 0
	
	# Jump
	if Input.is_action_just_pressed("jump") and jump_counter < 2:
		jump_counter += 1
		velocity.y = JUMP_SPEED

func process_movement(delta):
	# Set speed and target velocity
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = dir * speed
	
	# Smooth out the player's movement
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	current_vel = current_vel.linear_interpolate(target_vel, accel * delta)
	
	velocity.x = current_vel.x
	velocity.z = current_vel.z
	
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))

func process_weapons():
	if Input.is_action_just_pressed("empty"):
		weapon_manager.change_weapon("Empty")
	if Input.is_action_just_pressed("primary"):
		weapon_manager.change_weapon("Primary")
	if Input.is_action_just_pressed("secondary"):
		weapon_manager.change_weapon("Secondary")



func _input(event):
	if event is InputEventMouseMotion:
		# Rotates the view vertically
		$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
		
		# Rotates the view horizontally
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					weapon_manager.next_weapon()
				BUTTON_WHEEL_DOWN:
					weapon_manager.previous_weapon()



# To show/hide the cursor
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

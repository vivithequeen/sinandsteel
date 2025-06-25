extends CharacterBody3D


const SPEED = 8.0
const MAXSPEED = 8.0;
const JUMP_VELOCITY = 7
const LOOK_SENSE := 0.0025;
var dashLocation : Vector3
var isDashing : bool = false;
var dashSpeed : float = 30
@onready var camera : Camera3D = $Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !isDashing:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
#		velocity = clamp(velocity,velocity.length(),Vector3(MAXSPEED,0,MAXSPEED).normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if(isDashing):
		global_position = lerp(global_position,dashLocation,delta*dashSpeed)
		if is_equal_approx(global_position.x, dashLocation.x) && is_equal_approx(global_position.z, dashLocation.z):
			isDashing = false;

	if(Input.is_action_just_pressed("shift")):
		isDashing = true;
		dashLocation = $dashLocation.global_position

	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * LOOK_SENSE * 0.5);
		camera.rotate_x(-event.relative.y * LOOK_SENSE)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2,PI/2)

extends CharacterBody3D


const SPEED = 12.0
const MAXSPEED = 8.0;
const JUMP_VELOCITY = 8
const LOOK_SENSE := 0.0025;
const dashDistance := 14;

@onready var camera : Camera3D = $Camera3D

var hasJumpedTwice : bool = false
#dash stuff
var dashLocation : Vector3
var isDashing : bool = false;
var dashSpeed : float = 1.54;
var dashTimer = 0;

#slide
var slideDirection : Vector3;
var isSliding : bool = false;

var isMoving : bool = false;
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$dashLocation.position = Vector3(0*dashDistance, 0, -1*dashDistance)
func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor() && !isDashing:
		velocity.y += -16 * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or !hasJumpedTwice):
		velocity.y = JUMP_VELOCITY
		if(!hasJumpedTwice):
			hasJumpedTwice = true;
	if(is_on_floor()):
		hasJumpedTwice = false;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	handle_camera_move(delta,input_dir);
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:


		$dashLocation.position = Vector3(input_dir.x*dashDistance, 0, input_dir.y*dashDistance)
	if direction and !isDashing:
		isMoving = false;
#		$fovAnimations.play("move_end")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
#		velocity = clamp(velocity,velocity.length(),Vector3(MAXSPEED,0,MAXSPEED).normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

	handle_dash(delta);
	handle_slide(delta);
	move_and_slide()

func handle_camera_move(delta : float, input_dir : Vector2):
	pass



func handle_slide(delta : float):
	if(Input.is_action_just_pressed("ctrl")):
		if(velocity * Vector3(1,0,1)):
			slideDirection = velocity * Vector3(1,0,1);
		else:
			slideDirection = transform.basis*Vector3(0,0,-1) * SPEED
			
	if(Input.is_action_pressed("ctrl")):
		isSliding = true;
		
	else:
		isSliding = false;
	
	if(isSliding):
		velocity.x = slideDirection.x
		velocity.z = slideDirection.z
	camera.position.y = 0 if isSliding else 1;
func handle_dash(delta : float):
	if(Input.is_action_just_pressed("shift")):
		velocity.y = 0;
		$fovAnimations.play("dash_start")
		isDashing = true;
		dashLocation = $dashLocation.global_position
	if(isDashing):
		dashTimer+=delta*dashSpeed
		global_position = global_position.lerp(dashLocation,dashTimer)
		if (dashTimer>=0.99):
			$fovAnimations.play("dash_end")
			dashTimer = 0
			isDashing = false;


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * LOOK_SENSE * 0.5);
		camera.rotate_x(-event.relative.y * LOOK_SENSE)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2,PI/2)


func _on_area_3d_body_entered(body):
	isDashing = false;
	dashTimer = 0
	$fovAnimations.play("dash_end");

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
var current_amount_of_dashes = 0
const AMOUNT_OF_DASHES_MAX : int = 3;
const SLIDE_MUTI : float = 1.4;

#general movement
var isMoving : bool = false;

var hasDashed : bool = false;
var hasSlided : bool = false;
var timeOnFloor : float = 0;
var currentSpeedFov : float = 0;
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_amount_of_dashes = AMOUNT_OF_DASHES_MAX
	$dashLocation.position = Vector3(0*dashDistance, 0, -1*dashDistance)
func _physics_process(delta):
	var speedMuti : float = 1.0;
	speedMuti+= 0.38 if hasSlided else 0
	speedMuti+= 0.38 if hasDashed else 0
	# Add the gravity.
	if !is_on_floor() && !isDashing:
		velocity.y += -16 * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or !hasJumpedTwice) and !isSliding :
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

	if(is_on_floor()):
		if(!isSliding and !isDashing):
			timeOnFloor+=delta
		if(timeOnFloor >= 0.35):
			speedMuti = 1;
			hasSlided = false;
			hasDashed = false;
	else:
		timeOnFloor = 0
	if direction and !isDashing:
		
		isMoving = false;
#		$fovAnimations.play("move_end")
		velocity.x = direction.x * SPEED * speedMuti
		velocity.z = direction.z * SPEED * speedMuti
		
#		velocity = clamp(velocity,velocity.length(),Vector3(MAXSPEED,0,MAXSPEED).normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	currentSpeedFov = 90 + (10 if hasSlided else 0) + (10 if hasDashed else 0) + (15 if input_dir.y !=0 else 0)

	if(!isDashing):
		runFov();
		straftCameraTurn(input_dir)
	handle_dash(delta);
	handle_slide(delta);
	$temp_ui/Label.text = "FOV: " + str(camera.fov)
	move_and_slide()

func handle_camera_move(delta : float, input_dir : Vector2):
	pass



func handle_slide(delta : float):
	if(Input.is_action_just_pressed("ctrl") and is_on_floor()):
		isSliding = true;
		hasSlided = true;
		if(velocity * Vector3(1,0,1)):
			slideDirection = velocity * Vector3(1,0,1) * SLIDE_MUTI;
		else:
			slideDirection = transform.basis*Vector3(0,0,-1) * SPEED * SLIDE_MUTI
			
	if(Input.is_action_pressed("ctrl")):

		pass
	else:
		isSliding = false;
	
	if(isSliding):
		hasSlided = true;
		if(Input.is_action_just_pressed("ui_accept") and is_on_floor()):
			velocity.y +=JUMP_VELOCITY
			isSliding = false;
		velocity.x = slideDirection.x
		velocity.z = slideDirection.z
	$CollisionShape3D.shape.height = 1 if isSliding else 2
	$CollisionShape3D.position.y = -0.5 if isSliding else 0.0
	camera.position.y = 0 if isSliding else 1;

func handle_dash(delta : float):
	if(is_on_floor()):
		current_amount_of_dashes = AMOUNT_OF_DASHES_MAX
	if(Input.is_action_just_pressed("shift")) and current_amount_of_dashes >0:
		current_amount_of_dashes-=1;
		velocity.y = 0;
		hasDashed =true
		startDashFov()
		isDashing = true;
		dashLocation = $dashLocation.global_position
	if(isDashing):
		dashTimer+=delta*dashSpeed
		global_position = global_position.lerp(dashLocation,dashTimer)
		if (dashTimer>=0.99):
			endDashFov()
			dashTimer = 0
			isDashing = false;

func straftCameraTurn(input_dir : Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"rotation:z",input_dir.x*-deg_to_rad(7.5),0.5)

func runFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov",currentSpeedFov,0.3)


func endDashFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov",currentSpeedFov,0.1)

func startDashFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"fov",110,0.1)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * LOOK_SENSE * 0.5);
		camera.rotate_x(-event.relative.y * LOOK_SENSE)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2,PI/2)


func _on_area_3d_body_entered(body):
	isDashing = false;
	dashTimer = 0
	endDashFov()
	
	

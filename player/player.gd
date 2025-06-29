extends CharacterBody3D


const SPEED = 12.0
const MAXSPEED = 12;
const JUMP_VELOCITY = 8
const LOOK_SENSE := 0.0025;
const dashDistance := 14;
const GRAVITY := -16.0

@onready var camera: Camera3D = $Camera3D

var hasJumpedTwice: bool = false
#dash stuff
var dashLocation: Vector2
var isDashing: bool = false;
var dashSpeed: float = 54;
var dashTimer = 0;
var dashDirection: Vector2;

#slide
var slideDirection: Vector3;
var isSliding: bool = false;
var current_amount_of_dashes = 0

const AMOUNT_OF_DASHES_MAX: int = 3;
const SLIDE_MUTI: float = 1.4;


#general movement
var isMoving: bool = false;

var hasDashed: bool = false;
var hasSlided: bool = false;
var hasWallRun: bool = false;
var timeOnFloor: float = 0;
var currentSpeedFov: float = 0;

var isPlumeting: bool = false
#headbob
var headbobSpeed: float = 6; # headbobs per second
var headbobTimer: float = 0;
const headbobLength: float = 0.4;

#wallrun
var isWallRunning: bool = false
var wallRunTimer: float = 0
var timeWallRunning: float = 0
var canWallJump: bool = true

const WALLRUN_SPEED_MUTI: float = 1.2
func _ready():
	$Camera3D/pixelfilter.size = get_viewport().size


	current_amount_of_dashes = AMOUNT_OF_DASHES_MAX

func _physics_process(delta):
	var speedMuti: float = 1.0;
	speedMuti += 0.35 if hasSlided else 0.0
	speedMuti += 0.25 if hasDashed else 0.0
	speedMuti += 0.3 if hasWallRun else 0.0
	# Add the gravity.
	if !is_on_floor() && !isDashing:
		if (isPlumeting):
			velocity.y = GRAVITY * delta * 200
		else:
			velocity.y += GRAVITY * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("space") and (is_on_floor() or !hasJumpedTwice) and !isSliding:
		velocity.y = JUMP_VELOCITY
		if (isWallRunning):
			isWallRunning = false;
			
			wallRunTimer = 0.3;
		if (!hasJumpedTwice):
			hasJumpedTwice = true;
	if (is_on_floor()):
		isPlumeting = false;
		canWallJump = true
		if (!isSliding):
			headbob(delta)
		hasJumpedTwice = false;


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


	if (timeOnFloor >= 0.35 && (is_on_floor() || input_dir.x == 0)):
		speedMuti = 1;
		hasSlided = false;
		hasDashed = false;
		hasWallRun = false;
	if (is_on_floor()):
		if (!isSliding and !isDashing):
			if (timeOnFloor <= 0.35):
				timeOnFloor += delta

	else:
		timeOnFloor = 0
	if direction and !isDashing and !isPlumeting:
		isMoving = false;
#		$fovAnimations.play("move_end")
		velocity.x = direction.x * SPEED * speedMuti
		velocity.z = direction.z * SPEED * speedMuti
		
#		velocity = clamp(velocity,velocity.length(),Vector3(MAXSPEED,0,MAXSPEED).normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	currentSpeedFov = 90 + (14 if hasSlided else 0) + (8 if hasDashed else 0) + (12 if hasWallRun else 0) + (15 if input_dir.y != 0 else 0)
	#if (!checkIfCanDash()):
	#	if (isDashing):
	#		isDashing = false;
	#		dashTimer = 0
	#		endDashFov()
	if (!isDashing):
		runFov();
		straftCameraTurn(input_dir)
	
	handle_slide(delta);
	handle_wallrun(delta)
	handle_dash(delta,input_dir);
	weaponHold(delta, input_dir)

	#velocity.x = clamp(velocity.x,-MAXSPEED * (direction.x if direction.x else 1),MAXSPEED * (direction.x if direction.x else 1))
	#velocity.z = clamp(velocity.z,-MAXSPEED * (direction.z if direction.z else 1),MAXSPEED * (direction.z if direction.z else 1))
	
	move_and_slide()

func weaponHold(delta, input_dir):
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property($Camera3D/holdingThing, "position:y", sin(headbobTimer) * 0.02 + -0.23 + (0.0 if velocity.y < 0 else -0.025) + (0.0 if velocity.y > 0 else 0.025), 0.7)
	if (!isSliding): tween.parallel().tween_property($Camera3D/holdingThing, "rotation:z", input_dir.x * -deg_to_rad(9.5) * (-1 if isWallRunning else 1), 0.5)
	tween.parallel().tween_property($Camera3D/holdingThing, "position:z", (0.15 if input_dir.y == 1 else 0.0), 0.5)
func headbob(delta):
	if (velocity.x + velocity.z != 0):
		headbobTimer += delta * headbobSpeed
	if (headbobTimer > PI):
		headbobTimer = 0;
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",sin(headbobTimer) * headbobLength + 1,0.1)


func handle_wallrun(delta: float):
	$Camera3D/temp_ui/Label.text = str(wallRunTimer)
	if ($raycastleft.is_colliding() && Input.is_action_pressed("left") and !is_on_floor() and wallRunTimer <= 0 and !isPlumeting):
		isWallRunning = true;

	elif ($raycastright.is_colliding() && Input.is_action_pressed("right") and !is_on_floor() and wallRunTimer <= 0 and !isPlumeting):
		isWallRunning = true;

	else:
		timeWallRunning = 0;
		isWallRunning = false;
	if (isWallRunning):
		timeWallRunning += delta
		velocity.y = 0;
		

		velocity *= WALLRUN_SPEED_MUTI

		velocity.y += GRAVITY / 12.0
		if (Input.is_action_just_pressed("space") and canWallJump):
			hasWallRun = true;
			velocity.y += JUMP_VELOCITY * 1.4
			canWallJump = false;
			isWallRunning = false
			wallRunTimer = 0.5
			hasJumpedTwice = false;
	if (wallRunTimer >= 0):
		wallRunTimer -= delta

		#velocity.x= (transform.basis * Vector3(1,0,0)).normalized().x * SPEED/16;

func handle_slide(delta: float):
	if (Input.is_action_just_pressed("ctrl") and !isDashing):
		if (is_on_floor()):
			isSliding = true;

			if (velocity * Vector3(1, 0, 1)):
				slideDirection = velocity * Vector3(1, 0, 1) * SLIDE_MUTI;
			else:
				slideDirection = transform.basis * Vector3(0, 0, -1) * SPEED * SLIDE_MUTI
		else:
			isPlumeting = true
			
	if (Input.is_action_pressed("ctrl")):
		pass
	else:
		if (!$up_check.is_colliding()):
			isSliding = false;
	
	if (isSliding):
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "rotation:z", (slideDirection.x / abs(slideDirection.x)) * -deg_to_rad(7.5) * (-1 if isWallRunning else 1), 0.5)
		
		
		if (Input.is_action_just_pressed("space") ):
			hasSlided = true;
			velocity.y += JUMP_VELOCITY
			isSliding = false;
		velocity.x = slideDirection.x
		velocity.z = slideDirection.z
	$CollisionShape3D.shape.height = 1 if isSliding else 2
	$CollisionShape3D.position.y = -0.5 if isSliding else 0.0
	
	if (is_on_floor()):
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "position:y", 0.0 if isSliding else 0.75, 0.1)


func handle_dash(delta: float,input_dir):
	if (is_on_floor()):
		current_amount_of_dashes = AMOUNT_OF_DASHES_MAX
	if (Input.is_action_just_pressed("shift")) and current_amount_of_dashes > 0  and !isDashing and !isSliding:
		if (velocity * Vector3(1, 0, 1)):
			dashDirection = Vector2(velocity.normalized().x,velocity.normalized().z) * Vector2(1,1)
		else:
			dashDirection =  Vector2((Vector3(0,0,-1) * transform.basis).x,(Vector3(0,0,-1) * transform.basis).z)
		isPlumeting = false;
		current_amount_of_dashes -= 1;
		velocity.y = 0;
		
		startDashFov()
		isDashing = true;
		
	if (isDashing):
		velocity.x = dashDirection.x * dashSpeed
		velocity.z = dashDirection.y * dashSpeed
		hasDashed = true

		dashTimer += delta

		if (dashTimer >= 0.2):
			endDashFov()
			dashTimer = 0
			isDashing = false;


func straftCameraTurn(input_dir: Vector2):
	if (!isDashing and !isSliding):
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "rotation:z", input_dir.x * -deg_to_rad(7.5) * (-1 if isWallRunning else 1), 0.5)

func runFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", currentSpeedFov, 0.5)


func endDashFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", currentSpeedFov, 0.1)

func startDashFov():
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "fov", currentSpeedFov + 5, 0.1)

func _input(event):
	if(!get_node("../").paused):
		if event is InputEventMouseMotion:
			rotation.y += (-event.relative.x * LOOK_SENSE * 0.5);
			camera.rotation.x += (-event.relative.y * LOOK_SENSE)
			camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

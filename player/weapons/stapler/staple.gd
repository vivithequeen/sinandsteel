extends Node3D

var startPos : Vector3
var moveDirection : Vector3
var startRotation : Vector3

const SPEED : float = 1;#1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = startPos
	global_rotation = startRotation;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	global_position+=moveDirection.normalized() * SPEED


func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is StaticBody3D:
		moveDirection = Vector3.ZERO
		$despawn_timer.start()


func _on_despawn_timer_timeout() -> void:
	queue_free()


func _on_despawn_timer_2_timeout() -> void:
	queue_free()

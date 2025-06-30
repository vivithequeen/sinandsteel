extends Node3D

var canShotgunJump = true
func _physics_process(delta: float) -> void:
	if(get_node("../../../").is_on_floor()):
		canShotgunJump = true
	if(Input.is_action_just_pressed("lmb") and canShotgunJump):
		get_node("../../../").velocity.y = 10
		canShotgunJump = false

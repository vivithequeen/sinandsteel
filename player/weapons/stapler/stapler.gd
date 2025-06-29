extends Node3D

var stapleProjectile = preload("res://player/weapons/stapler/staple.tscn")

const COOLDOWN : float = 0.1
var cooldownTimer : float = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(cooldownTimer>=0):
		cooldownTimer-=delta
	if(Input.is_action_pressed("lmb")) and cooldownTimer <=0:
		cooldownTimer = COOLDOWN
		print("pp poo poo")
		var proj = stapleProjectile.instantiate();
		proj.startPos = $spawn.global_position
		proj.moveDirection = $dist.global_position - $spawn.global_position 
		proj.startRotation = global_rotation
		get_node("../../../../").add_child(proj)

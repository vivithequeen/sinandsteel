extends Node3D

var stapleProjectile = preload("res://player/weapons/shotgun/shotgunbullet.tscn")
var spread = 0.025/8
const COOLDOWN : float = 1
var cooldownTimer : float = 0;
var bulletAmount : int = 24
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(cooldownTimer>=0):
		cooldownTimer-=delta
	if(Input.is_action_pressed("lmb")) and cooldownTimer <=0:

		$shotgunanimations.play("fire")
		for i in bulletAmount:
			$dist.position.x = -0.066 + randf_range(-spread, spread)
			$dist.position.y = 0.155 + randf_range(-spread, spread)
			cooldownTimer = COOLDOWN
			print("pp poo poo")
			var proj = stapleProjectile.instantiate();
			proj.startPos = $spawn.global_position
			proj.moveDirection = $dist.global_position - $spawn.global_position 
			proj.startRotation = global_rotation
			get_node("../../../../").add_child(proj)

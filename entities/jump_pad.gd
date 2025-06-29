extends Node3D


@export var jumpHeight : float = 25



func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is CharacterBody3D:
		body.velocity.y = jumpHeight

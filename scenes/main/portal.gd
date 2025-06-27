extends MeshInstance3D

@export var oppositePortal: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.material = StandardMaterial3D.new();
	mesh.material.albedo_texture = oppositePortal.get_node("SubViewport").get_texture();
	$SubViewport/Camera3D.global_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

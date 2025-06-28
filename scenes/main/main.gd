extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	fixMeshs(self)

func fixMeshs(s):
	print(self)
	for i in s.get_children():
		print(self)
		if(i is MeshInstance3D):
			print(i)
			for j in i.mesh.get_surface_count():
				print(j)
				if(i.mesh.surface_get_material(j)):
					i.mesh.surface_get_material(j).texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC;

		elif(i is StaticBody3D):
			i.set_collision_layer_value(4, true)
			i.set_collision_mask_value(4, true)
		else:
			fixMeshs(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_deathbox_body_entered(body):
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

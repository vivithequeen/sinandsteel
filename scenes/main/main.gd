extends Node3D

var paused : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	update_mouse_mode()
	fixMeshs(self)

func fixMeshs(s):
	for i in s.get_children():

		if(i is StaticBody3D):
			i.set_collision_layer_value(4, true)
			i.set_collision_mask_value(4, true)
		else:
			fixMeshs(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(paused):
		pass

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("f1")):
		paused = !paused
		update_mouse_mode()
func _on_deathbox_body_entered(body):
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func update_mouse_mode():

	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	else:

		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

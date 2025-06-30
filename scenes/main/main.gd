extends Node3D

var paused : bool = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if(paused):
#		ImGui.Begin("Level Selection")
#		if(ImGui.TreeNode("Oblivious")):
#			if(ImGui.Button("Load Level 1")):
#				get_tree().change_scene_to_file("res://scenes/main/main.tscn")
#			ImGui.TreePop();
#		ImGui.End()

#func _input(event: InputEvent) -> void:
#	if(event.is_action_pressed("f1")):
#		paused = !paused
#		update_mouse_mode()
func _on_deathbox_body_entered(body):
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

#func update_mouse_mode():
#
#	if paused:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#
#	else:
#
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

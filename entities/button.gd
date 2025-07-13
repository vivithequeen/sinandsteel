extends Node3D

var on = false
@export var onByDefault : bool;
@export var activateWhenPressed : Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(onByDefault):
		for i in activateWhenPressed:
			i.turn_on()	


func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.name == "Player":
		if(!on):
			for i in activateWhenPressed:
				i.turn_on()
		on = true;

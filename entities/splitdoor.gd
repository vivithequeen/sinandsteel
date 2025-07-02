extends Node3D


func open()->void:
	$ani.play("open")


func close()->void:
	$ani.play_backwards("open")

func turn_on():
	open()
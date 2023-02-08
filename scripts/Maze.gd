extends Node

class_name Maze

onready var player : = $Player

func _on_Level1_level_completed():
	player.queue_free()
	get_tree().change_scene("res://scenes/Credits.tscn")

extends Button

export(PackedScene) var scene;

func _pressed():
	return get_tree().change_scene_to(scene)

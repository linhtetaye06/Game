extends TextureButton

const target_scene = "res://main.tscn"

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var error = get_tree().change_scene_to_file(target_scene)
	if error != OK:
		print("Failed to change scene!")

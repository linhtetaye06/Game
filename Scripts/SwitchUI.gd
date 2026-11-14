extends Area2D

@export_file("*.tscn") var next_ui_scene: String

func _on_input_event(viewport: Node, event: InputEvent, shape_idx:int) -> void : 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT : 
		if next_ui_scene:
			get_tree().change_scene_to_file(next_ui_scene)
			

extends Node

@onready var warning_label = $Warning/WarningContainer
var warning_timer: SceneTreeTimer

func show_screen_warning(text: String) -> void:
	if not warning_label:
		return
		
	warning_label.text = text
	warning_label.visible = true
	
	await get_tree().create_timer(5.0).timeout
	
	if is_instance_valid(warning_label):
		warning_label.text = ""
		warning_label.visible = false

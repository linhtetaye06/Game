extends GridContainer

@export var texture_on: Texture2D
@export var texture_off: Texture2D

var panel_buttons: Array[TextureButton] = []
var panel_states: Array[bool] = []

func _ready() -> void:
	for child in get_children():
		if child is TextureButton:
			panel_buttons.append(child)
	
	for i in range(panel_buttons.size()):
		var btn = panel_buttons[i]
		btn.pressed.connect(_on_panel_pressed.bind(i))
		
		var device_key = "solar_%d" % (i + 1)
		var is_on = true
		
		if GameProcessing and GameProcessing.devices.has(device_key):
			is_on = GameProcessing.devices[device_key].device_on
			
		panel_states.append(is_on)
		btn.texture_normal = texture_on if is_on else texture_off

func _on_panel_pressed(index: int) -> void:
	panel_states[index] = not panel_states[index]
	var btn = panel_buttons[index]
	
	if panel_states[index]:
		btn.texture_normal = texture_on
	else:
		btn.texture_normal = texture_off
		
	if GameProcessing:
		GameProcessing.set_solar_panel_state(index, panel_states[index])

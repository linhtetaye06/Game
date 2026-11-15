extends Node2D


@export var texture_on: Texture2D
@export var texture_off: Texture2D

var miner_buttons: Array[TextureButton] = []
var miner_states: Array[bool] = []

func _ready() -> void:
	miner_buttons.clear()
	miner_states.clear()
	
	for child in get_children():
		if child is TextureButton:
			miner_buttons.append(child)
	
	for i in range(miner_buttons.size()):
		var btn = miner_buttons[i]
		if not btn.pressed.is_connected(_on_miner_pressed): 
			btn.pressed.connect(_on_miner_pressed.bind(i))
		
		var device_key = "miner_%d" % (i + 1)
		var is_on = true
		
		if GameProcessing and GameProcessing.devices.has(device_key):
			is_on = GameProcessing.devices[device_key].device_on
			
		miner_states.append(is_on)
		btn.texture_normal = texture_on if is_on else texture_off

func _on_miner_pressed(index: int) -> void:
	miner_states[index] = not miner_states[index]
	var btn = miner_buttons[index]
	
	if miner_states[index]:
		btn.texture_normal = texture_on
	else:
		btn.texture_normal = texture_off
		
	if GameProcessing:
		GameProcessing.set_miner_state(index, miner_states[index])

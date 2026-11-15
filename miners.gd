extends GridContainer

@export var game_backend: MoonBaseGame 
@export var texture_on: Texture2D
@export var texture_off: Texture2D

var miner_buttons: Array[TextureButton] = []
var miner_states: Array[bool] = []

func _ready() -> void:
	for child in get_children():
		if child is TextureButton:
			miner_buttons.append(child)
	
	for i in range(miner_buttons.size()):
		var btn = miner_buttons[i]
		btn.pressed.connect(_on_miner_pressed.bind(i))
		
		var device_key = "solar_%d" % (i + 1)
		var is_on = true
		
		if game_backend and game_backend.devices.has(device_key):
			is_on = game_backend.devices[device_key].device_on
			
		miner_states.append(is_on)
		btn.texture_normal = texture_on if is_on else texture_off

func _on_miner_pressed(index: int) -> void:
	miner_states[index] = not miner_states[index]
	var btn = miner_buttons[index]
	
	if miner_states[index]:
		btn.texture_normal = texture_on
	else:
		btn.texture_normal = texture_off
		
	if game_backend:
		game_backend.set_miner_state(index, miner_states[index])

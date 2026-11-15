extends TextureButton

@export var texture_on: Texture2D
@export var texture_off: Texture2D

var is_on: bool = false

func _ready() -> void:
 if GameProcessing and GameProcessing.devices.has("processor"):
  is_on = GameProcessing.devices["processor"].device_on
  texture_normal = texture_on if is_on else texture_off

 if not pressed.is_connected(_on_pressed):
  pressed.connect(_on_pressed)

func _on_pressed() -> void:
 is_on = not is_on
 texture_normal = texture_on if is_on else texture_off
 
 if GameProcessing:
  GameProcessing.set_processor_state(is_on)

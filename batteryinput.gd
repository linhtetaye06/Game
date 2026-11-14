extends Area2D

var power_deposit: float = 0.0
@onready var batterypopup: Control = $BatteryUI/Batterypopup
@onready var line_edit: LineEdit = $BatteryUI/Batterypopup/VBoxContainer/LineEdit
@onready var confirm_button: Button = $BatteryUI/Batterypopup/VBoxContainer/Button

func _ready() -> void:
	if batterypopup:
		batterypopup.visible = false
	if confirm_button:
		confirm_button.pressed.connect(_on_deposit_confirmed)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if batterypopup:
			batterypopup.visible = not batterypopup.visible

func _on_deposit_confirmed() -> void:
	var entered_text = line_edit.text
	if entered_text.is_valid_float():
		# Store the typed value into your placeholder variable
		power_deposit = entered_text.to_float()
		
		# Quick print to check in your Output tab that it saved correctly
		print("Power deposit stored: ", power_deposit)
		
		# Close the popup and clear the box
		batterypopup.visible = false
		line_edit.clear()
	else:
		print("Please enter a valid number.")

extends Control

@onready var buttons: Dictionary = {
	"solar_1": $GridContainer/solarpanel1
}

var texture_on: Texture2D = preload("res://Assests/solarpanelon.png")
var texture_off: Texture2D = preload("res://Assests/solarpaneloff.png")

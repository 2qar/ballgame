extends Control

signal name_entered(name)

var player_name : String

func _ready():
	$input.connect("text_changed", self, "_on_text_changed")
	$input.connect("text_entered", self, "_on_text_entered")
	$accept.connect("pressed", self, "_on_accept_pressed")

func _on_text_changed(text):
	player_name = text

func _on_text_entered(text):
	check_name(text)

func _on_accept_pressed():
	check_name(player_name)

func check_name(name):
	if name.empty():
		$invalid_name_popup.popup()
	else:
		emit_signal("name_entered", name)

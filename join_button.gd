extends Button

signal join(ip)

func _on_join_button_pressed():
	var ip = OS.get_clipboard()
	if ip.is_valid_ip_address():
		emit_signal("join", ip)
	else:
		$invalid_ip_popup.popup()

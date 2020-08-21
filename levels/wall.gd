extends StaticBody2D

func _ready():
	$Timer.connect("timeout", self, "_on_timeout")

func _on_timeout():
	$collider.disabled = not $collider.disabled
	if $collider.disabled:
		$Sprite.modulate.a = 0.5
	else:
		$Sprite.modulate.a = 1

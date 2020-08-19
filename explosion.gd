extends Timer

func _ready():
	wait_time = $particles.lifetime
	connect("timeout", self, "_on_timeout")
	start()
	$particles.emitting = true

func particles() -> Node:
	return $particles

func _on_timeout():
	queue_free()

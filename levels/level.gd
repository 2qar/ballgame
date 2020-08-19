extends Node2D

signal level_cleared

func _ready():
	$ball.connect("goal_hit", self, "_on_goal_hit")

func _on_goal_hit(pos):
	$ball.queue_free()
	var explosion = preload("res://explosion.tscn").instance()
	explosion.particles().position = pos
	explosion.connect("timeout", self, "_on_explosion_completed")
	add_child(explosion)

func _on_explosion_completed():
	emit_signal("level_cleared")

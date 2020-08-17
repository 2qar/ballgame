extends Node2D

export(PoolColorArray) var colors

func _ready():
	$lobby.connect("start_game", self, "_on_start_game")
	$ball.connect("die", self, "_on_ball_die")

func remove_color(c: Color):
	for i in range(colors.size()):
		if colors[i] == c:
			colors.remove(i)
			break

func _on_start_game(players):
	randomize()
	var players_with_colors = {}
	for id in players:
		var color = colors[randi() % colors.size()]
		remove_color(color)
		players_with_colors[id] = {
			"color": color,
			"name": players[id]
		}
	print(players_with_colors)
	rpc("spawn_players", players_with_colors)

remotesync func spawn_players(players):
	$lobby.queue_free()
	var x = 64
	for id in players:
		var player = preload("res://player.tscn").instance()
		player.set_name(str(id))
		player.set_network_master(id)
		player.set_color(players[id]["color"])
		if id == get_tree().get_network_unique_id():
			player.remove_nametag()
		else:
			player.set_nametag(players[id]["name"])
		player.translate(Vector2(x, 64))
		add_child(player)
		x += 128

func _on_ball_die():
	var ball = preload("res://ball.tscn").instance()
	add_child(ball)

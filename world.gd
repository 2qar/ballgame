extends Node2D

export(PoolColorArray) var colors
export(Array, PackedScene) var levels
var levels_index = -1
var current_level : Node2D
var player_list : Dictionary

func _ready():
	$lobby.connect("start_game", self, "_on_start_game")

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
	rpc("spawn_players", players_with_colors)

remotesync func spawn_players(players):
	player_list = players
	$lobby.queue_free()
	advance_level()

func advance_level():
	var level = load_next_level()
	add_players_to_level(level)

func add_players_to_level(level: Node2D):
	var x = 64
	for id in player_list:
		var player = preload("res://player.tscn").instance()
		player.set_name(str(id))
		player.set_network_master(id)
		player.set_color(player_list[id]["color"])
		if id == get_tree().get_network_unique_id():
			player.remove_nametag()
		else:
			player.set_nametag(player_list[id]["name"])
		player.translate(Vector2(x, 64))
		level.add_child(player)
		x += 128

func load_next_level() -> Node:
	if current_level != null:
		current_level.disconnect("level_cleared", self, "_on_level_cleared")
		current_level.queue_free()
	
	levels_index += 1
	var level = levels[levels_index].instance()
	level.connect("level_cleared", self, "_on_level_cleared")
	add_child(level)
	current_level = level
	return level

func _on_level_cleared():
	advance_level()

extends Node2D

signal start_game(players)

const max_players = 4
const port = 4269

var host_ip : String
var player_name : String
var players = {}

func _ready():
	$host_button.connect("pressed", self, "_on_host_button_pressed")
	$join_button.connect("join", self, "_on_join")
	$name_input.connect("name_entered", self, "_on_name_entered")
	$start_button.connect("pressed", self, "_on_start_pressed")
	
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	
	player_name = OS.get_environment("USERNAME")
	if player_name.empty():
		player_name = "host"
	add_player(1, player_name)

func _on_host_button_pressed():
	$join_button.disabled = true
	$start_button.disabled = false
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().network_peer = peer

func _on_start_pressed():
	emit_signal("start_game", players)
	get_tree().network_peer.refuse_new_connections = true

func _on_join(ip):
	$join_button.disabled = true
	$host_button.disabled = true
	$name_input.visible = true
	host_ip = ip

func _on_name_entered(name):
	$name_input.visible = false
	player_name = name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_ip, port)
	get_tree().network_peer = peer

func _on_network_peer_disconnected(id):
	rpc("remove_player", id)

# TODO: 3rd player not seeing connecting?
func _on_connected_to_server():
	rpc("add_player", get_tree().get_network_unique_id(), player_name)
	rpc_id(1, "request_sync")

remotesync func add_player(id: int, name: String):
	players[id] = name
	$players.add_item(name)
	$players.set_item_metadata($players.get_item_count()-1, id)

remotesync func remove_player(id: int):
	players.erase(id)
	for i in range($players.get_item_count()):
		if $players.get_item_metadata(i) == id:
			$players.remove_item(i)
			break

remote func sync_players(new_players):
	players = new_players
	$players.clear()
	for id in players:
		add_player(id, players[id])

remote func request_sync():
	rpc_id(get_tree().get_rpc_sender_id(), "sync_players", players)

func _on_connection_failed():
	print("connection failed")

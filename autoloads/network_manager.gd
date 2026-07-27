extends Node
#O&O reserved IP: 192.168.2.8
# "home" reserved IP: idk


# Autoload named Network Manager

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var PORT = 35432#35_000
var DEFAULT_SERVER_IP = "81.204.249.19"#"192.168.2.8"#"127.0.0.1" # IPv4 localhost, replace with server
const MAX_CONNECTIONS = 5

# This will contain player info for every player,
# with the keys being each player's unique IDs.
@export var players = {}

var connection_type := "player"


#func _process(delta: float) -> void:
	#print("from network_manager: ", players)

func _ready():
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if OS.has_feature("dedicated_server"):
		connection_type = "dedicated"
		print("tries to create game from NetworkManager")
		create_game(PORT)


func join_game(address = "", port: int = PORT):
	print("Joining")
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(DEFAULT_SERVER_IP, port)
	if error:
		print("Couldnt join")
		return error
	multiplayer.multiplayer_peer = peer


func create_game(port: int):
	print("tries to create game from root")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = connection_type
	player_connected.emit(1, connection_type)


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func on_player_connected(id):
	_register_player.rpc_id(id, connection_type)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	print("Player ", id, " Left")
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	print("Connected")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = connection_type
	player_connected.emit(peer_id, connection_type)


func _on_connected_fail():
	print("Couldn't Join")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_server_disconnected():
	print("Server Disconnected")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	server_disconnected.emit()

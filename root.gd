extends Node

@export var level_scene: PackedScene
var dedicated_correction: int = 0

@onready var connection_timer: Timer = $ConnectionTimer
@onready var players_joined_label: Label = $MainMenuStuff/PlayersJoined

var port: int


func _ready() -> void:
	#var a = IP.get_local_addresses()
	#var b = IP.get_local_interfaces()
	#print("aaa: ", a)
	#print("aab: ", b)
	if randi_range(0, 0) == 0:
		port = 30_000
	else:
		port = 40_000

	$MainMenuStuff/Port.text = str(port)
	players_joined_label.visible = false

	$MainMenuStuff/ButtonContainer/Start.grab_focus()  # for keyboard/controller use
	
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)

func _on_player_connected(_pid, info):
	connection_timer.stop()
	if info == "dedicated":
		dedicated_correction = 1
		assert(false, "turns out something is dedicated")
	players_joined_label.text = "Players in Lobby: %s" %(NetworkManager.players.size() - dedicated_correction)
	players_joined_label.visible = true

func _on_player_disconnected(_pid):
	players_joined_label.text = "Players in Lobby: %s" %(NetworkManager.players.size() - dedicated_correction)

# If any player presses this, it starts the game for everyone
@rpc("any_peer", "call_local", "reliable")
func start_game():
	print("load game got called")
	var level = level_scene.instantiate()
	$Levels.add_child(level)
	$Background.visible = false
	$MainMenuStuff.visible = false

@rpc("any_peer", "call_local")
func request_start_game():
	if multiplayer.is_server():
		print("load game call 'succesful'")
		start_game.rpc()
		# only server loads scene. MultiplayerSpawner spawns it for everyone

func create_game():
	NetworkManager.create_game(port)
	#print("tries to create game from root")
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(port, 5)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer
#
	##players[1] = connection_type
	##player_connected.emit(1, connection_type)

func join_game():
	NetworkManager.join_game("", port)
	# Start a timer to check if joining
	connection_timer.start()
	players_joined_label.text = "Joining..."
	players_joined_label.visible = true


func _on_connection_timer_timeout() -> void:
	NetworkManager._on_connected_fail()
	players_joined_label.text = "Connection Timed Out"

func _on_server_disconnected() -> void:
	# Back to main menu
	var levels_children = $Levels.get_children()
	for child in levels_children:
			child.queue_free()
	
	$MainMenuStuff.visible=true
	$Background.visible = true
	players_joined_label.text = "Lost Connection to Server"


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	request_start_game.rpc_id(1)


func _on_host_pressed() -> void:
	create_game()


func _on_join_pressed() -> void:
	join_game()

extends Node

@onready var spawn_points: Node = $SpawnPoints
@onready var players: Node = $Players

@export var player_scene: PackedScene


var is_dedicated: bool = false

func _ready() -> void:
	if NetworkManager.players.is_empty():
		# singleplayer situation
		NetworkManager.players = {1: NetworkManager.connection_type}
	
	for i in NetworkManager.players:
		if NetworkManager.players[i] == "dedicated":
			is_dedicated = true
			print("Running on Dedicated Server")
	
	# everyone needs to know this
	if multiplayer.is_server():
		spawn_all_players.rpc()


@rpc("authority", "call_local")
func spawn_all_players():
	var spawnpoints := spawn_points.get_children()
	var pid_array := NetworkManager.players.keys()

	if is_dedicated:
		pid_array.erase(1)
		# Removes dedicated server as a player
	pid_array.sort()  
	# this makes sure that the spawnpoints are in order. Not needed, just debug

	for i in pid_array.size():
		var pid = pid_array[i%10]
		var spawnpoint = spawnpoints[i].global_position
		var new_player = player_scene.instantiate()
		new_player.position = spawnpoint
		new_player.name = str(pid)
		new_player.set_multiplayer_authority(pid) # prefer it here over players _ready
		$Players.add_child(new_player)


func _on_xp_timer_timeout() -> void:
	for player: Player in players.get_children():
		player.stats_menu.gain_xp.rpc(102)
	print("everyone got xp !")

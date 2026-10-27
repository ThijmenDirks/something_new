extends Node

@onready var spawn_points: Node = $SpawnPoints
@onready var players: Node = $Players
@onready var items_node: Node = $Items

@export var player_scene: PackedScene

var all_item_ids: Array[int] = []
var all_items: Dictionary = {}
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
		set_item_ids.rpc()


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


@rpc("authority", "call_local")
func set_item_ids() -> void:
	for i in range(items_node.get_children().size()):
		var item = items_node.get_child(i)
		if item is Item:
			print("setting id to: ", i + 100)
			item.set_id(i+100)
			all_items[i+100] = item


func _on_xp_timer_timeout() -> void:
	print("authoro? ", multiplayer.is_server())
	for player: Player in players.get_children():
		player.stats_menu.gain_xp.rpc(202)
		#player.stats_menu.current_hp -= 2
		#print("test 1")
		#player.take_damage_server_side(5, player)
	print("everyone got xp !")

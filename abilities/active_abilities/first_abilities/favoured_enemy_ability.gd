extends FirstAbility

@onready var cooldown_timer: Timer = $CooldownTimer
const FAVOURED_ENEMY_POINTER = preload("uid://cpehpgksbvdmy")

var last_player_hit: Player # or just any creature

var favoured_enemy: Player


var my_pointer: Area2D

#func get_added() -> void:
	#super()
	#my_area = Area2D.new()
	#my_area.set_collision_layer_value(1, false)
	#my_owner.ability_areas.add_child(my_area)
	#var new_collision_shape: CollisionShape2D = CollisionShape2D.new()
	#new_collision_shape.shape = CircleShape2D.new()
	#new_collision_shape.shape.radius = 800
	#my_area.add_child(new_collision_shape)

func get_used() -> void:
	request_get_used.rpc_id(1)

@rpc("authority", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left != 0 or not last_player_hit:
		return
	get_used_server_side()
	get_used_client_side.rpc()

func get_used_server_side() -> void:
	cooldown_timer.start()
	favoured_enemy = last_player_hit
	#remove_pointer.rpc()
	#remove_pointer.rpc_id(get_multiplayer_authority())
	#place_pointer()

@rpc("any_peer", "call_local")
func get_used_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1 or not my_owner.is_multiplayer_authority():
		return
	#if my_owner.is_multiplayer_authority():
	cooldown_timer.start()
	favoured_enemy = last_player_hit
	print("hi")
	#remove_pointer()
	place_pointer()

func place_pointer() -> void:
	my_pointer = FAVOURED_ENEMY_POINTER.instantiate()
	#my_pointer.global_position = my_owner.global_position
	my_pointer.target = favoured_enemy
	my_pointer.set_multiplayer_authority(my_owner.get_multiplayer_authority())
	my_owner.ability_areas.add_child(my_pointer)

@rpc("any_peer", "call_local")
func remove_pointer():
	if not multiplayer.get_remote_sender_id() == 1 or not my_owner.is_multiplayer_authority():
		return
	if is_instance_valid(my_pointer):
		push_warning("test 1")
		my_owner.ability_areas.remove_child(my_pointer)
		push_warning("test 2")
		my_pointer.queue_free()
		push_warning("test 3")

func get_removed() -> void:
	remove_pointer.rpc()

#@rpc("any_peer", "call_local")
#func remove_area() -> void:
	#if not multiplayer.get_remote_sender_id() == 1:
		#return
	#print("from peer: ", multiplayer.get_unique_id(), " my_areas parent: ", my_area.get_parent())
	#my_area.get_parent().remove_child(my_area)
	#my_area.queue_free()


func has_done_damage(args: Array) -> Array:
	last_player_hit = args[1]
	return args

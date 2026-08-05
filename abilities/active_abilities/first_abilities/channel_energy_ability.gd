extends FirstAbility


@onready var cooldown_timer: Timer = $CooldownTimer
@onready var area_2d: Area2D = $Area2D

var healing: int = 20

var my_area: Area2D

func get_added() -> void:
	super()
	my_area = Area2D.new()
	my_area.set_collision_layer_value(1, false)
	my_owner.ability_areas.add_child(my_area)
	var new_collision_shape: CollisionShape2D = CollisionShape2D.new()
	new_collision_shape.shape = CircleShape2D.new()
	new_collision_shape.shape.radius = 800
	my_area.add_child(new_collision_shape)

func _enter_tree() -> void:
	super()
	get_node("Area2D").global_position = my_owner.global_position

func get_used() -> void:
	print(self, " got used !")
	request_get_used.rpc_id(1)


@rpc("authority", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left == 0:
		get_used_server_side()
		get_used_client_side.rpc()


func get_used_server_side() -> void:
	cooldown_timer.start()
	for player: Player in my_area.get_overlapping_bodies():
		player.take_healing_server_side(healing, my_owner)

@rpc("any_peer", "call_local")
func get_used_client_side() -> void:
	cooldown_timer.start()
	if not multiplayer.get_remote_sender_id() == 1:
		return
	my_owner.strength += 5


func get_removed() -> void:
	remove_area.rpc()

@rpc("any_peer", "call_local")
func remove_area() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	print("from peer: ", multiplayer.get_unique_id(), " my_areas parent: ", my_area.get_parent())
	my_area.get_parent().remove_child(my_area)
	my_area.queue_free()

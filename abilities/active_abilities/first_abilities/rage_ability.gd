extends FirstAbility

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var duration_timer: Timer = $DurationTimer

var is_active: bool = false

func get_used() -> void:
	print(self, " got used !")
	request_get_used.rpc_id(1)


@rpc("authority", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left == 0 and duration_timer.time_left == 0:
		get_used_server_side()
		#get_used_client_side.rpc_id(get_multiplayer_authority())
		get_used_client_side.rpc()


func get_used_server_side() -> void:
	is_active = true
	my_owner.stats_menu.change_stat(0, 5)
	duration_timer.start()

@rpc("any_peer", "call_local")
func get_used_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	is_active = true
	my_owner.strength += 5
	duration_timer.start()
	add_label_for_debug()

@rpc("any_peer", "call_local")
func end_rage():
	if not is_inside_tree():
		return
	if (not multiplayer.get_remote_sender_id() == 1) and (not is_multiplayer_authority()):
		return
	if is_active:
		is_active = false
		my_owner.stats_menu.change_stat(0, -5)
		cooldown_timer.start()
		remove_label_for_debug()


func _on_duration_timer_timeout() -> void:
	if not multiplayer.is_server():
		end_rage()
	else:
		end_rage.rpc()


func take_damage_server_side(args: Array) -> Array:
	if not multiplayer.is_server():
		return args
	if is_active:
		return [args[0] * 0.5] # 0.75
	return args


func get_removed() -> void:
	end_rage.rpc()

var label_for_debug: Label

func add_label_for_debug():
	label_for_debug = Label.new()
	label_for_debug.text = "RAGE !!!"
	label_for_debug.position.y = -180
	my_owner.add_child(label_for_debug)

func remove_label_for_debug():
	if label_for_debug.is_inside_tree():
		label_for_debug.queue_free()
		pass

#func take_damage_server_side(args: Array) -> Array:
	#if not multiplayer.is_server():
		#return args
	#var damage: int = args[0]
	#if is_active == true:
		#damage *= 0.75
		#args = [damage]
	#return args

extends SecondAbility

@onready var cooldown_timer: Timer = $CooldownTimer
const TRAP = preload("uid://287nwhf4d0xl")

func get_used() -> void:
	request_get_used.rpc_id(1)

@rpc("authority", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left != 0:
		return
	get_used_server_side()
	get_used_client_side.rpc()

func get_used_server_side() -> void:
	cooldown_timer.start()
	add_trap()

@rpc("any_peer", "call_local")
func get_used_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	if my_owner.is_multiplayer_authority():
		cooldown_timer.start()
		add_trap()


func add_trap():
	var new_trap = TRAP.instantiate()
	new_trap.placer = my_owner
	new_trap.global_position = my_owner.global_position
	my_owner.get_parent().get_parent().add_child(new_trap)

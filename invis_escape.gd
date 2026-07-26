extends PassiveAbility

@onready var timer: Timer = $Timer


func take_damage_client_side(damage: int):
	# only to show animation and such, idk what exaclty
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pass

func take_damage_server_side(args: Array) -> Array:
	if not multiplayer.is_server():
		return args
	my_owner.visible = false
	timer.start()
	update_invisibility.rpc()
	return args

@rpc("any_peer")
func update_invisibility():
	if not multiplayer.get_remote_sender_id() == 1:
		return
	my_owner.visible = false

@rpc("any_peer")
func update_visibility():
	if not multiplayer.get_remote_sender_id() == 1:
		return
	my_owner.visible = true


func _on_timer_timeout() -> void:
	if not multiplayer.is_server():
		return
	my_owner.visible = true
	update_visibility.rpc()

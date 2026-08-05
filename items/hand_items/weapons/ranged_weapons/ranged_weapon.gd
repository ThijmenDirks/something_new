class_name RangedWeapon extends Weapon

@export var ammo: int = 999 # maybe ammo for amout, munition for type ?

var my_projectile: Resource = preload("uid://buhs8ealr14vi")

func _enter_tree() -> void:
	super()

func get_used() -> void:
	if timer.time_left != 0: # gets checked again at the server_side
		return
	request_get_used.rpc_id(1)


@rpc("any_peer", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server() or not (multiplayer.get_remote_sender_id() == my_owner.get_multiplayer_authority()):
		return

	if timer.time_left == 0 and ammo > 1:
		get_used_verified()
		ammo -= 1 # make some func for this, to handle when ammo goes to 0
		timer.start()
		add_projectile.rpc()


@rpc("any_peer", "call_local")
func add_projectile(_selected_projectile = null) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var shooter: Player = null
	var new_projectile: projectile = my_projectile.instantiate()
	new_projectile.set_multiplayer_authority(1)
	if multiplayer.is_server():
		shooter = my_owner
		if shooter == null:
			shooter = my_owner
		new_projectile.shooter = shooter
		new_projectile.speed += (shooter.dexterity - 10) * 20
		new_projectile.global_position = global_position
		new_projectile.direction = Vector2(cos(rotation), sin(rotation))
		new_projectile.rotation = new_projectile.direction.angle()
	print("ranged weapon used !")
	my_owner.get_parent().get_parent().add_child(new_projectile)

@rpc("any_peer", "call_local") # but should it be call_local ?
func get_used_verified() -> void:
	if not is_multiplayer_authority() or not multiplayer.get_remote_sender_id() == 1:
		return
	# play some animation ?
	timer.start()
	ammo -= 1

class_name MeleeWeapon extends Weapon

@export var rotation_speed: float = 5 # in rad
@export var reach_angle: float = PI # in rad

# it will be: request attack(time of attack)
# everyone sees attack
# server validates attack, and if so, deals damage based on ping

func _enter_tree() -> void:
	#super()
	my_owner = get_parent().get_parent().get_parent()
	set_multiplayer_authority(my_owner.get_multiplayer_authority())
	rotation = randf_range(0, TAU)
	visible = is_multiplayer_authority()
	if is_instance_valid(get_parent()):
		if get_parent().name == "RightHand":
			print("is in right hand !")
		elif get_parent().name == "LeftHand":
			print("is in left hand !")
			rotation_speed *= -1
		else:
			print("hand is called: ", get_parent().name)

func _process(delta: float) -> void:
	#super()
	rotation = wrapf(rotation + rotation_speed * delta, 0, TAU)

func get_used() -> void:
	if timer.time_left != 0: # gets checked again at the server_side
		return
	request_get_used.rpc_id(1)

@rpc("call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return

	if timer.time_left == 0:
		timer.start()
		for body in get_overlapping_bodies():
			if body == my_owner:
				continue
			var angle_weapon_to_target: float = angle_difference(Vector2(body.global_position - global_position).angle(), rotation)
			if angle_weapon_to_target < reach_angle/2 and angle_weapon_to_target > -reach_angle/2:
				var damage: int = get_damage_from_angle(angle_weapon_to_target)
				print("body: ", body, " will take ", damage, " damage ", multiplayer.get_peers())
				# can only be called from server, and will be called to server, so no rpc needed
				body.take_damage_server_side(damage)

func get_damage_from_angle(angle) -> int:
	return round(max_damage * cos(angle))

@rpc("any_peer", "call_local") # but should it be call_local ?
func get_used_verified() -> void:
	if not is_multiplayer_authority() or not multiplayer.get_remote_sender_id() == 1:
		return
	#3 play some animation ?
	timer.start()

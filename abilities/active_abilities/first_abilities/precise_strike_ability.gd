extends FirstAbility

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var duration_timer: Timer = $DurationTimer

var is_active: bool = false
var normal_rotation_speed: float

# the rotation speed is an exported var on a scene instances. since the scene will get freed when unequiped and newly made when equiped, rotation speed can savely be changed

func get_used() -> void:
	print(self, " got used !")
	request_get_used.rpc_id(1)


@rpc("authority", "call_local")
func request_get_used() -> void:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left == 0 and duration_timer.time_left == 0:
		get_used_server_side()
		get_used_client_side.rpc()


func get_used_server_side() -> void:
	is_active = true
	if my_owner.right_hand_node.get_child_count() != 0:
		if my_owner.right_hand_node.get_child(0) is MeleeWeapon:
			normal_rotation_speed = my_owner.right_hand_node.get_child(0).rotation_speed
			#assert(false, str(normal_rotation_speed))
			print("but why? ", normal_rotation_speed)
			my_owner.right_hand_node.get_child(0).rotation_speed = 0
			is_active = true
			duration_timer.start()

@rpc("any_peer", "call_local")
func get_used_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	if my_owner.right_hand_node.get_child_count() != 0:
		if my_owner.right_hand_node.get_child(0) is MeleeWeapon:
			var a = my_owner.right_hand_node.get_child(0).rotation_speed
			if a != 0:
				normal_rotation_speed = a
			my_owner.right_hand_node.get_child(0).rotation_speed = 0
			is_active = true
			duration_timer.start()
			add_label_for_debug()

			if my_owner.is_multiplayer_authority():
				duration_timer.start()


@rpc("any_peer", "call_local")
func end_ability():
	#ALERT are the next two lines needed ?
	if not is_inside_tree():
		return
	if (not multiplayer.get_remote_sender_id() == 1) and (not is_multiplayer_authority()):
		return
	if is_active:
		is_active = false
		cooldown_timer.start()
		remove_label_for_debug()
		if my_owner.right_hand_node.get_child_count() != 0:
			if my_owner.right_hand_node.get_child(0) is MeleeWeapon:
				if my_owner.right_hand_node.get_child(0).rotation_speed == 0:
					print("all the way till here ! ", normal_rotation_speed)
					my_owner.right_hand_node.get_child(0).rotation_speed = normal_rotation_speed


func _on_duration_timer_timeout() -> void:
	if not multiplayer.is_server():
		end_ability()
	else:
		end_ability.rpc()


func get_removed() -> void:
	end_ability.rpc()

var label_for_debug: Label

func add_label_for_debug():
	label_for_debug = Label.new()
	label_for_debug.text = "precise strike"
	label_for_debug.position.y = -180
	my_owner.add_child(label_for_debug)

func remove_label_for_debug():
	if label_for_debug.is_inside_tree():
		label_for_debug.queue_free()
		pass

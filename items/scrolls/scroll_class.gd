class_name Scroll extends Item

@export var my_spell: Dictionary

func get_picked_up() -> void:
	super()
	add_scroll_to_equiped_spell()

func add_scroll_to_equiped_spell() -> void:
	my_owner.add_spell(my_spell)

@rpc("any_peer", "call_local")
func request_get_decipered() -> void:
	if (not multiplayer.is_server()) or (multiplayer.get_remote_sender_id() != my_owner.multiplayer.get_unique_id()):
		return
	if my_spell["is_arcane_otherwise_divine"]:
		if my_owner.can_cast_arcane_spells >= my_spell["level"]:
			get_decipered_verified.rpc_id(multiplayer.get_remote_sender_id())
	else:
		if my_owner.can_cast_divine_spells >= my_spell["level"]:
			get_decipered_verified.rpc_id(multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_local")
func get_decipered_verified() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return

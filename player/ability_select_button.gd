class_name AbilitySelectButton extends TextureButton

enum TYPE {
	FIRST,
	SECOND,
	PASSIVE
}

@onready var stats_menu: Control = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

#@export var my_ability: PackedScene
@export var my_ability_name: String
@export var my_ability: Dictionary
@export var type: TYPE
@export var is_unlocked: bool = false

func _enter_tree() -> void:
	my_ability = AbilityDatabse.get(my_ability_name)
	if my_ability != null:
		pass
	#var my_ability_instance = my_ability.instantiate()
	#texture_normal = my_ability["select_logo"]
	$Sprite2D.texture = load("res://assets/100-ability-icons-v0-i8bs7g98z7gf1.png")#.frame = my_ability["logo_frame"]
	$Sprite2D.hframes = 10
	$Sprite2D.vframes = 10
	$Sprite2D.frame = my_ability["logo_frame"]
	$VBoxContainer/PanelContainer/Label.text = my_ability.description
	$VBoxContainer/UnlockButton.visible = not is_unlocked
	$VBoxContainer/PickButton.visible = is_unlocked

	if my_ability["type"] == 1:
		type = TYPE.FIRST
	elif my_ability["type"] == 2:
		type = TYPE.SECOND
	elif my_ability["type"] == 0:
		type = TYPE.PASSIVE
	else:
		assert(false, str(my_ability, " ", my_ability))


func _on_pressed() -> void:
	print("select pressed: ", my_ability_name, " abil: ", my_ability)
	if $VBoxContainer.visible:
		$VBoxContainer.visible = false
	else:
		$VBoxContainer.visible = true

func _on_pick_button_pressed() -> void:
	request_pick.rpc_id(1)

@rpc("call_local")
func request_pick() -> void:
	if not multiplayer.is_server():
		return
	if is_unlocked and stats_menu.is_leveling:
		stats_menu.change_ability_server_side(my_ability["my_file_path"])


func _on_unlock_button_pressed() -> void:
	request_unlock.rpc_id(1)

@rpc("call_local")
func request_unlock() -> void:
	if not multiplayer.is_server():
		return
	print("is leveling: ",stats_menu.is_leveling, " levels left: ", stats_menu.pending_levels)
	if stats_menu.is_leveling and stats_menu.pending_levels > 0:
		unlock.rpc()

# maybe there have to be a server and client version, just like a lot of funcs have
@rpc("any_peer", "call_local")
func unlock() ->void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	stats_menu.change_pending_levels(-1)
	is_unlocked = true
	$VBoxContainer/UnlockButton.visible = false
	$VBoxContainer/PickButton.visible = true


#func _enter_tree() -> void:
	#if my_ability != null:
		#pass
	#var my_ability_instance = my_ability.instantiate()
	#texture_normal = my_ability_instance.select_logo
	#if my_ability_instance is FirstAbility:
		#type = TYPE.FIRST
	#elif my_ability_instance is SecondAbility:
		#type = TYPE.SECOND
	#elif my_ability_instance is PassiveAbility:
		#type = TYPE.PASSIVE
	#else:
		#assert(false, str(my_ability, " ", my_ability_instance))

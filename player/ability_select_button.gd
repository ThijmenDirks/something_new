class_name AbilitySelectButton extends TextureButton

enum TYPE {
	FIRST,
	SECOND,
	PASSIVE
}

@export var my_ability: PackedScene
@export var type: TYPE
@export var is_unlocked: bool = true

func _enter_tree() -> void:
	if my_ability != null:
		pass
	var my_ability_instance = my_ability.instantiate()
	texture_normal = my_ability_instance.select_logo
	if my_ability_instance is FirstAbility:
		type = TYPE.FIRST
	elif my_ability_instance is SecondAbility:
		type = TYPE.SECOND
	elif my_ability_instance is PassiveAbility:
		type = TYPE.PASSIVE
	else:
		assert(false, str(my_ability, " ", my_ability_instance))

func _on_pressed() -> void:
	request_on_pressed.rpc_id(1)

@rpc("call_local")
func request_on_pressed() -> void:
	if not multiplayer.is_server():
		return
	if is_unlocked:
		get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().change_ability_server_side.rpc_id(1, my_ability)

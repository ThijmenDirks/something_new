extends PanelContainer

enum MY_STAT {
	STRENGTH,
	DEXTERITY,
	INTELLIGENCE
}

@export var my_stat: MY_STAT

@onready var stats_menu: Control = get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var amount_label: Label = $VBoxContainer/HBoxContainer/AmountLabel

func _enter_tree() -> void:
	if my_stat == MY_STAT.STRENGTH:
		$VBoxContainer/HBoxContainer/StatLabel.text = "Strength"
	if my_stat == MY_STAT.DEXTERITY:
		$VBoxContainer/HBoxContainer/StatLabel.text = "Dexterity"
	if my_stat == MY_STAT.INTELLIGENCE:
		$VBoxContainer/HBoxContainer/StatLabel.text = "Intelligence"


func _on_button_pressed() -> void:
	print("thingy autho: ", get_multiplayer_authority())
	request_change_stat.rpc_id(1)

@rpc("call_local")
func request_change_stat() -> void:
	if not multiplayer.is_server():
		return
	if stats_menu.pending_stat_boosts > 0:
		change_stat_server_side()
		change_stat_client_side.rpc()

func change_stat_server_side() -> void:
	stats_menu.change_pending_stat_boosts(-1)
	stats_menu.change_stat(my_stat, 1)

@rpc("any_peer", "call_local")
func change_stat_client_side() -> void:
	if (not multiplayer.get_remote_sender_id() == 1) or (multiplayer.is_server()):
		return
	stats_menu.change_pending_stat_boosts(-1)
	stats_menu.change_stat(my_stat, 1)

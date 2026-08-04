extends CanvasLayer

@onready var chat_label_container: VBoxContainer = $Interface/Panel/ChatLabelContainer
@onready var ping_label: Label = $PingLabel
@onready var stats_menu: Control = $StatsMenu
@onready var joystick: Control = $TouchScreenButtons/Joystick

var is_in_stats_menu: bool = false

var player: Player

func _ready() -> void:
	player = get_parent()



func _on_right_hand_button_pressed() -> void:
	if is_in_stats_menu:
		return
	print("right hand used !!")
	player.use_right_hand()

func _on_left_hand_button_pressed() -> void:
	if is_in_stats_menu:
		return
	player.use_left_hand()

func _on_first_ability_button_pressed() -> void:
	if is_in_stats_menu:
		return
	player.use_first_ability()

func _on_second_ability_button_pressed() -> void:
	if is_in_stats_menu:
		return
	player.use_second_ability()

func _on_cast_spell_button_pressed() -> void:
	if is_in_stats_menu:
		return
	player.start_casting_spell()
	#get_parent().get_node("SpellCastSystem")._on_cast_spell_button_pressed()


func _on_stats_menu_button_pressed() -> void:
	is_in_stats_menu = true
	joystick.visible = false
	stats_menu.setup()

func exit_stats_menu():
	is_in_stats_menu = false
	joystick.visible = true

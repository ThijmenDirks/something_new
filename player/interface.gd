extends CanvasLayer

@onready var chat_label_container: VBoxContainer = $Interface/Panel/ChatLabelContainer
@onready var ping_label: Label = $PingLabel
@onready var stats_menu: Control = $StatsMenu
@onready var joystick: Control = $TouchScreenButtons/Joystick

@onready var first_ability_button: TouchScreenButton = $TouchScreenButtons/FirstAbilityButton
@onready var second_ability_button: TouchScreenButton = $TouchScreenButtons/SecondAbilityButton

#@onready var pick_up_item_button: TouchScreenButton = $TouchScreenButtons/PickUpItemButton
#@onready var pickup_menu: Control = $PickupMenu

var is_in_stats_menu: bool = false

var player: Player

func _ready() -> void:
	player = get_parent()

func _physics_process(delta: float) -> void:
	update_button_progress()

func update_button_progress():
	return
	# this block should be cleaned up
	var first = $StatsMenu/MarginContainer/HBoxContainer/Classtuff/SelectedClasses/HBoxContainer/FirstAbility
	var second = $StatsMenu/MarginContainer/HBoxContainer/Classtuff/SelectedClasses/HBoxContainer/SecondAbility
	if first.get_child_count() != 0:
		if first.get_child(0).get_node("CooldownTimer").time_left != 0:
			first_ability_button.get_node("TextureProgressBar").fill_mode = 2
			first_ability_button.get_node("TextureProgressBar").value = first.get_child(0).get_node("CooldownTimer").time_left / first.get_child(0).get_node("CooldownTimer").wait_time
		elif first.get_child(0).has_node("DurationTimer"):#.time_left != 0:
			if first.get_child(0).get_node("CooldownTimer").time_left != 0:
				first_ability_button.get_node("TextureProgressBar").fill_mode = 3
				first_ability_button.get_node("TextureProgressBar").value = first.get_child(0).get_node("DurationTimer").time_left / first.get_child(0).get_node("DurationTimer").wait_time

	if second.get_child_count() != 0:
		if second.get_child(0).get_node("CooldownTimer").time_left != 0:
			second_ability_button.get_node("TextureProgressBar").fill_mode = 2
			second_ability_button.get_node("TextureProgressBar").value = second.get_child(0).get_node("CooldownTimer").time_left / second.get_child(0).get_node("CooldownTimer").wait_time
		elif second.get_child(0).has_node("DurationTimer"):#.time_left != 0:
			if second.get_child(0).get_node("CooldownTimer").time_left != 0:
				second_ability_button.get_node("TextureProgressBar").fill_mode = 3
				second_ability_button.get_node("TextureProgressBar").value = second.get_child(0).get_node("DurationTimer").time_left / second.get_child(0).get_node("DurationTimer").wait_time


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


func _on_pickup_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
	# add the new item to the ground invenotry if there is space left
	if area is Item:
		stats_menu.inventory.add_item_to_ground_inventory(area)


func _on_pickup_area_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
	# remove the item from the ground inventory.
	# then, loop trough the get_overlapping_areas() and add the first item that is not already in ground_inventory

	if area is Item:
		stats_menu.inventory.item_exited(area)
		#remove_item_from_ground_inventory(area.my_dict)


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if multiplayer.is_server(): # might probably want to only make the area moinitor in the server
		if body is Item:
			stats_menu.inventory.body_entered.rpc_id(1, body.my_id)
			stats_menu.inventory.body_entered.rpc_id(get_multiplayer_authority(), body.my_id)

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if multiplayer.is_server(): # might probably want to only make the area moinitor in the server
		if body is Item:
			stats_menu.inventory.body_exited.rpc_id(1, body.my_id)
			stats_menu.inventory.body_exited.rpc_id(get_multiplayer_authority(), body.my_id)

class_name FirstAbility extends ActiveAbility


func get_added() -> void:
	super()
	my_owner.get_node("Interface/TouchScreenButtons/FirstAbilityButton/Sprite2D").frame = get_node("Logo").frame

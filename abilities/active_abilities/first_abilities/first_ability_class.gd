class_name FirstAbility extends ActiveAbility


func get_added():
	super()
	my_owner.get_node("Interface/TouchScreenButtons/FirstAbilityButton/Sprite2D").frame = logo_frame

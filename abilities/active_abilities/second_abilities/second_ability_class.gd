class_name SecondAbility extends ActiveAbility


func get_added():
	super()
	my_owner.get_node("Interface/TouchScreenButtons/SecondAbilityButton/Sprite2D").frame = logo_frame

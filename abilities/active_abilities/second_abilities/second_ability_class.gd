class_name SecondAbility extends ActiveAbility


func get_added() -> void:
	super()
	my_owner.get_node("Interface/TouchScreenButtons/SecondAbilityButton/Sprite2D").frame = get_node("Logo").frame

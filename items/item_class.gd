class_name Item extends Area2D # Might gonna extend something else, in which case weapons need a lil tree overhaul

#var my_owner: Node
@onready var my_owner: Player# = get_parent().get_parent().get_parent()
@export var my_dic: Dictionary # not sure wheter this will be used

func _enter_tree() -> void:
	my_owner = get_parent().get_parent().get_parent()
	if is_instance_valid(my_owner):
		set_multiplayer_authority(my_owner.get_multiplayer_authority())

func get_picked_up() -> void:
	pass

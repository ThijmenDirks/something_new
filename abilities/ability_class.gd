class_name Ability extends Node2D

var my_owner: Player

var is_unlocked: bool = false
var is_in_use: bool = false

@export var allows_spellcasting: bool = false

func _enter_tree() -> void:
	my_owner = get_parent().get_parent().get_parent()

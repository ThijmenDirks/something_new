class_name Ability extends Node2D

var my_owner: Player

var is_unlocked: bool = false
var is_in_use: bool = false

@export var allows_spellcasting: bool = false
@export var select_logo: Texture

func _enter_tree() -> void:
	my_owner = get_parent().get_parent().get_parent()

func get_added():
	pass

func get_removed():
	pass

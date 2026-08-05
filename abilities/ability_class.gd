class_name Ability extends Node2D

var my_owner: Player

var is_unlocked: bool = false
var is_in_use: bool = false

@export var allows_arcane_spellcasting: int = 0
@export var allows_divine_spellcasting: int = 0
@export var select_logo: Texture
#@export var logo_frame: int

func _enter_tree() -> void:
	my_owner = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

func get_added() -> void:
	my_owner = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	set_multiplayer_authority(my_owner.get_multiplayer_authority())

func get_removed() -> void:
	queue_free()

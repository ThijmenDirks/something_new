class_name Spell extends Node2D

@export var niveau: int # 1, 2 or 3
@export var input_code: Array[int] # now done in spell_database
@export var is_from_scroll: bool = false
@export var is_aimable: bool = false # now done in spell_database
@export var target_position: Vector2 = Vector2.ZERO # not all spells use this # in global coords
@export var caster: Node#Player

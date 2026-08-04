extends Node


@export var shadow_clone_ability: Dictionary = {
	"my_file_path" : "res://abilities/active_abilities/first_abilities/shadow_clone_ability.tscn",
	"logo" : "res://assets/100-ability-icons-v0-i8bs7g98z7gf1.png", # not sure wheter i want it this way
	"description" : "Create 5 identical-looking\nshadows to fool others.",
	"logo_frame" : 71, # or this
	"type" : 1,
	"class" : "shadow_dancer",
}

@export var fireball_ability: Dictionary = {
	"my_file_path" : "res://abilities/active_abilities/second_abilities/fireball_ability.tscn",
	"logo" : "res://assets/100-ability-icons-v0-i8bs7g98z7gf1.png", # not sure wheter i want it this way
	"description" : "Cast a fireball, and allows\nto use scrolls (which do not yet exist).",
	"logo_frame" : 1, # or this
	"type" : 2,
	"class" : "wizard",
}

@export var invis_escape_ability: Dictionary = {
	"my_file_path" : "res://abilities/pasive_abilities/invis_escape_ability.tscn",
	"logo" : "res://assets/100-ability-icons-v0-i8bs7g98z7gf1.png", # not sure wheter i want it this way
	"description" : "When hit, turn invible\nfor 2 seconds.",
	"logo_frame" : 48, # or this
	"type" : 0,
	"class" : "shadow_dancer",
}

@export var rage_ability: Dictionary = {
	"my_file_path" : "res://abilities/active_abilities/first_abilities/rage_ability.tscn",
	"logo" : "res://assets/100-ability-icons-v0-i8bs7g98z7gf1.png", # not sure wheter i want it this way
	"description" : "become really angry\nto increase hitpoints and strength",
	"logo_frame" : 45, # or this
	"type" : 1,
	"class" : "barbarian",
}

var all_abilities: Array[Dictionary] = [shadow_clone_ability, fireball_ability, invis_escape_ability]

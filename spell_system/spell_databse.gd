extends Node


var fireball: Dictionary = {
	"my_file_path" : "res://spell_system/spells/fireball.tscn",
	"input_code" : [],
	"is_aimable" : true,
	"is_arcane_otherwise_divine" : true,
	"level" : 1,
	"is_for_ability" : true
}


var fireball_for_ability: Dictionary = {
	"my_file_path" : "res://spell_system/spells/fireball.tscn",
	"input_code" : [5, 6],
	"is_aimable" : true,
	"is_arcane_otherwise_divine" : true,
	"level" : 1,
	"is_for_ability" : true
}


var all_spells: Array[Dictionary] = [fireball]


#Nested typed collections are not supported.

var level_1_inputs: Array[Array] = [[5, 6]]
var level_2_inputs: Array[Array] = [[5, 6]]
var level_3_inputs: Array[Array] = [[5, 6]]

var used_level_1_inputs: Array[Array] = []
var used_level_2_inputs: Array[Array] = []
var used_level_3_inputs: Array[Array] = []

func _enter_tree() -> void:
	if multiplayer.is_server():
		redistribute_spell_inputs()

func redistribute_spell_inputs() -> void:
	for spell: Dictionary in all_spells:
		if spell["is_for_ability"]:
			continue
		if spell["level"] == 1:
			var searcing: bool = true
			while searcing:
				var random_input = level_1_inputs.pick_random()
				if random_input not in used_level_1_inputs:
					searcing = false
					spell["input_code"] = random_input
		if spell["level"] == 2:
			var searcing: bool = true
			while searcing:
				var random_input = level_2_inputs.pick_random()
				if random_input not in used_level_2_inputs:
					searcing = false
					spell["input_code"] = random_input
		if spell["level"] == 3:
			var searcing: bool = true
			while searcing:
				var random_input = level_3_inputs.pick_random()
				if random_input not in used_level_3_inputs:
					searcing = false
					spell["input_code"] = random_input

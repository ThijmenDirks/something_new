extends Node

var sword = {
	"my_file_path" : "res://items/hand_items/weapons/melee_weapons/melee_weapon.tscn", # ALERT this is thecalss, not the weapon
	"name" : "Sword",
	"description" : "Slice enemies with it!",
	"slot" : 1, # 0 for unequipable (such as scrolls), 1 for single-handed, 2 for two handed (bow, greatsword), 3 for armor
	#"ammo" : -1 # if used
	"frame" : 0
}


var scroll_of_fireball = {
	"my_scene" : "res://items/scrolls/scroll_of_fireball.tscn",
	"name" : "scroll of fireball",
	"description" : "damage creatures in an area",
	"slot" : 0, # 0 for unequipable (such as scrolls), 1 for single-handed, 2 for two handed (bow, greatsword), 3 for armor
	#"ammo" : 999
	"frame" : 31
}


var javelin = {
	"my_scene" : "res://items/hand_items/weapons/ranged_weapons/ranged_weapon.tscn", # ALERT this is thecalss, not the weapon
	"name" : "javelin",
	"description" : "one-handed long-range ranged weapon",
	"slot" : 1, # 0 for unequipable (such as scrolls), 1 for single-handed, 2 for two handed (bow, greatsword), 3 for armor
	#"ammo" : 999
	"frame": 55
}

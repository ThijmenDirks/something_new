extends Control

var all_items

@rpc("call_local")
func setup() -> void:
	get_parent().get_parent().pickup_area.get_overlapping_areas()

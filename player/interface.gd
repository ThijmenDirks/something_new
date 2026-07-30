extends CanvasLayer

@onready var chat_label_container: VBoxContainer = $Interface/Panel/ChatLabelContainer
@onready var ping_label: Label = $PingLabel

var player: Player

func _ready() -> void:
	player = get_parent()



func _on_right_hand_button_pressed() -> void:
	print("right hand used !!")
	player.use_right_hand()

func _on_left_hand_button_pressed() -> void:
	player.use_left_hand()

func _on_first_ability_button_pressed() -> void:
	player.use_first_ability()

func _on_second_ability_button_pressed() -> void:
	player.use_second_ability()

func _on_cast_spell_button_pressed() -> void:
	pass
	player.start_casting_spell()
	#get_parent().get_node("SpellCastSystem")._on_cast_spell_button_pressed()

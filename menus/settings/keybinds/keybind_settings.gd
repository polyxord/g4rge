## This menu is based on DashNothing's tutorial video about how to make
## keybind settings.
##
## @tutorial(Saving and Loading Settings): https://www.youtube.com/watch?v=ZDPM45cHHlI
extends ScrollContainer


var _is_remapping_keybind := false
var _inputs_to_remap: PackedStringArray = []
var _num_remaining_inputs_needed := 0
var _keybind_to_remap: String
var _remapping_button: Button

@onready var _keybind_list: VBoxContainer = %KeybindList


func _ready() -> void:
	var keybinds := ConfigHandler.load_settings("keybinds")
	for num_lanes in range(1, 11):
		var game_mode := str(num_lanes) + "k"
		var h_box_container := HBoxContainer.new()
		_keybind_list.add_child(h_box_container)
		var label := Label.new()
		h_box_container.add_child(label)
		label.text = game_mode
		#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#label.size_flags_stretch_ratio = 1.5
		label.custom_minimum_size.x = 60
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var button := Button.new()
		h_box_container.add_child(button)
		button.text = keybinds[game_mode]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void:
			if _is_remapping_keybind:
				return
			
			_is_remapping_keybind = true
			_keybind_to_remap = game_mode
			_num_remaining_inputs_needed = int(game_mode)
			_remapping_button = button
			button.text = "Press keys..."
		)


func _input(event: InputEvent) -> void:
	if (
			_is_remapping_keybind
			and event.is_action_pressed("ui_cancel")
	):
		_is_remapping_keybind = false
		_inputs_to_remap.clear()
		var keybind_settings := ConfigHandler.load_settings("keybinds")
		_remapping_button.text = keybind_settings[_keybind_to_remap]
		accept_event()
	
	if not (
			_is_remapping_keybind
			and event is InputEventKey
			and event.is_pressed()
	):
		return
	
	accept_event()
	var input_event_key := event as InputEventKey
	var keycode_str := OS.get_keycode_string(input_event_key.physical_keycode)
	_inputs_to_remap.append(keycode_str)
	var keybind_str := " ".join(_inputs_to_remap)
	_remapping_button.text = keybind_str
	_num_remaining_inputs_needed -= 1
	if _num_remaining_inputs_needed > 0:
		return
	
	_is_remapping_keybind = false
	_inputs_to_remap.clear()
	ConfigHandler.save_settings("keybinds", _keybind_to_remap, keybind_str)

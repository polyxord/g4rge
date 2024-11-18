extends ScrollContainer


@export var _screen_resolutions: Array[String]

@onready var _resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var _stretch_option_button: OptionButton = %StretchOptionButton
@onready var _scale_factor_value_label: Label = %ScaleFactorValueLabel
@onready var _scale_factor_h_slider: HSlider = %ScaleFactorHSlider
@onready var _fullscreen_option_button: OptionButton = %FullscreenOptionButton
@onready var _borderless_option_button: OptionButton = %BorderlessOptionButton
@onready var _v_sync_option_button: OptionButton = %VSyncOptionButton
@onready var _max_fps_spin_box: SpinBox = %MaxFPSSpinBox
@onready var _ups_spin_box: SpinBox = %UPSSpinBox


func _ready() -> void:
	var general_settings := ConfigHandler.load_settings("general")
	
	for resolution in _screen_resolutions:
		_resolution_option_button.add_item(resolution)
	var resolution_idx := _screen_resolutions.find(general_settings.resolution)
	_resolution_option_button.selected = resolution_idx
	_resolution_option_button.item_selected.connect(func(idx: int) -> void:
		var new_resolution := _screen_resolutions[idx]
		ConfigHandler.save_settings("general", "resolution", new_resolution)
		ConfigHandler.set_resolution(new_resolution)
	)
	
	_stretch_option_button.selected = general_settings.content_scale_mode
	_stretch_option_button.item_selected.connect(
		func(idx: Window.ContentScaleMode) -> void:
			ConfigHandler.save_settings("general", "content_scale_mode", idx)
			ConfigHandler.set_content_scale_mode(idx)
	)
	
	_scale_factor_value_label.text = "%.2f" % general_settings.content_scale_factor
	_scale_factor_h_slider.value = general_settings.content_scale_factor
	_scale_factor_h_slider.value_changed.connect(func(value: float) -> void:
		_scale_factor_value_label.text = "%.2f" % value
		ConfigHandler.save_settings("general", "content_scale_factor", value)
		ConfigHandler.set_content_scale_factor(value)
	)
	
	var set_borderless := func(idx: int) -> void:
		var is_borderless := bool(idx)
		ConfigHandler.save_settings("general", "borderless", is_borderless)
		ConfigHandler.set_borderless_window(is_borderless)
	_fullscreen_option_button.selected = int(general_settings.fullscreen)
	_fullscreen_option_button.item_selected.connect(func(idx: int) -> void:
		var is_fullscreen := bool(idx)
		# For some reason, having borderless enabled makes you lose focus of
		# the window when going fullscreen. This part prevents that by setting
		# the game to borderless before going fullscreen.
		if is_fullscreen:
			set_borderless.call(0)
			_borderless_option_button.selected = false
		_borderless_option_button.disabled = is_fullscreen
		ConfigHandler.save_settings("general", "fullscreen", is_fullscreen)
		ConfigHandler.set_fullscreen(is_fullscreen)
	)
	_borderless_option_button.disabled = _fullscreen_option_button.selected
	_borderless_option_button.selected = int(general_settings.borderless)
	_borderless_option_button.item_selected.connect(set_borderless)
	
	_v_sync_option_button.selected = int(general_settings.vsync)
	_v_sync_option_button.item_selected.connect(func(idx: int) -> void:
		var is_v_sync_enabled := bool(idx)
		ConfigHandler.save_settings("general", "vsync", is_v_sync_enabled)
		ConfigHandler.set_vsync_mode(is_v_sync_enabled)
		_max_fps_spin_box.editable = not is_v_sync_enabled
		_ups_spin_box.editable = not is_v_sync_enabled
	)
	
	_max_fps_spin_box.editable = not general_settings.vsync
	_max_fps_spin_box.value = general_settings.max_fps
	_max_fps_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("general", "max_fps", value)
		ConfigHandler.set_max_fps(value)
	)
	
	_ups_spin_box.editable = not general_settings.vsync
	_ups_spin_box.value = general_settings.ups
	_ups_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("general", "ups", value)
		ConfigHandler.set_ups(value)
	)

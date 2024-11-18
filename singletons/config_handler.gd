## A singleton that manages config file saving and loading.
##
## This singleton is based on DashNothing's tutorial video about saving and
## loading settings using the [ConfigFile] class.
##
## @tutorial(Saving and Loading Settings): https://www.youtube.com/watch?v=tfqJjDw0o7Y
extends Node


## File path for the config file.
const _SETTINGS_FILE_PATH := "user://settings.ini"

## [ConfigFile] to save to and load from.
var _config := ConfigFile.new()


func _ready() -> void:
	if not FileAccess.file_exists(_SETTINGS_FILE_PATH):
		_config.set_value("general", "resolution", "1152 x 648")
		_config.set_value("general", "content_scale_mode", 1)
		_config.set_value("general", "content_scale_factor", 1.0)
		_config.set_value("general", "fullscreen", false)
		_config.set_value("general", "borderless", false)
		_config.set_value("general", "vsync", true)
		# Refresh rate is doubled to reduce tearing when V-Sync is disabled.
		var screen_refresh_rate_doubled := 2 * int(_get_screen_refresh_rate())
		_config.set_value("general", "max_fps", screen_refresh_rate_doubled)
		_config.set_value("general", "ups", 960)
		
		_config.set_value("audio", "master_volume", 1.0)
		_config.set_value("audio", "music_volume", 1.0)
		_config.set_value("audio", "sfx_volume", 0.6)
		
		_config.set_value("keybinds", "1k", "Space")
		_config.set_value("keybinds", "2k", "Z Period")
		_config.set_value("keybinds", "3k", "C Space M")
		_config.set_value("keybinds", "4k", "Z X Comma Period")
		_config.set_value("keybinds", "5k", "X C Space M Comma")
		_config.set_value("keybinds", "6k", "Z X C M Comma Period")
		_config.set_value("keybinds", "7k", "Z X C Space M Comma Period")
		_config.set_value("keybinds", "8k", "Z X C V M Comma Period Slash")
		_config.set_value("keybinds", "9k", "Z X C V Space M Comma Period Slash")
		_config.set_value("keybinds", "10k", "A S D C Space M J I O P")
		
		_config.set_value("gameplay", "scroll_direction", "Down")
		_config.set_value("gameplay", "scroll_speed", 28)
		_config.set_value("gameplay", "audio_offset", 45)
		
		_config.save(_SETTINGS_FILE_PATH)
	else:
		_config.load(_SETTINGS_FILE_PATH)
	
	var general_settings := load_settings("general")
	set_resolution(general_settings.resolution)
	set_content_scale_mode(general_settings.content_scale_mode)
	set_content_scale_factor(general_settings.content_scale_factor)
	set_fullscreen(general_settings.fullscreen)
	set_borderless_window(general_settings.borderless)
	set_vsync_mode(general_settings.vsync)
	set_max_fps(general_settings.max_fps)
	set_ups(general_settings.ups)
	
	var audio_settings := load_settings("audio")
	set_volume("Master", audio_settings.master_volume)
	set_volume("Music", audio_settings.music_volume)
	set_volume("SFX", audio_settings.sfx_volume)


## Saves the [param key] and [param value] pair to the config file under
## [param section_name].
func save_settings(section_name: String, key: String, value: Variant) -> void:
	_config.set_value(section_name, key, value)
	_config.save(_SETTINGS_FILE_PATH)


## Returns settings from the config file under [param section_name].
func load_settings(section_name: String) -> Dictionary:
	var section_settings := {}
	for key in _config.get_section_keys(section_name):
		section_settings[key] = _config.get_value(section_name, key)
	return section_settings


## Sets the window to the given resolution.[br][br]
## [b]Example:[/b]
## [codeblock]
## set_resolution("1337 x 727")
## [/codeblock]
## [b]Note:[/b] [param resolution] must be formatted as
## [code]"width x height"[/code].
func set_resolution(resolution: String) -> void:
	var resolution_components := resolution.split(" x ")
	var width := int(resolution_components[0])
	var height := int(resolution_components[1])
	get_window().size = Vector2i(width, height)


## Sets the window's content scale mode to the given mode.
func set_content_scale_mode(mode: Window.ContentScaleMode) -> void:
	get_window().content_scale_mode = mode


## Sets the window's content scale factor to the given value.
func set_content_scale_factor(scale_factor: float) -> void:
	get_window().content_scale_factor = scale_factor


## If [code]true[/code], the window is set to fullscreen.
func set_fullscreen(is_fullscreen: bool) -> void:
	DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			if is_fullscreen
			else DisplayServer.WINDOW_MODE_WINDOWED
	)


## If [code]true[/code], the window is set to borderless.
func set_borderless_window(is_borderless: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,
			is_borderless)


## If [code]true[/code], V-Sync will be enabled on the window.
func set_vsync_mode(vsync_enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED
			if vsync_enabled
			else DisplayServer.VSYNC_DISABLED
	)
	_update_physics_steps_per_frame()


## Sets the game's maximum frames per second cap to the given value.
func set_max_fps(max_fps: int) -> void:
	Engine.max_fps = max_fps
	_update_physics_steps_per_frame()


## Sets the game's physics updates/ticks per second to the given value.
func set_ups(ups: int) -> void:
	Engine.physics_ticks_per_second = ups
	_update_physics_steps_per_frame()


## Sets the volume of the audio bus with [param bus_name] to a
## [param linear_energy] ranging from 0 to 1.
func set_volume(bus_name: String, linear_energy: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var decibels := linear_to_db(linear_energy)
	AudioServer.set_bus_volume_db(bus_index, decibels)


## Recalibrates the max number of physics steps allowed to run per frame based
## on multiple factors: ups, max fps, and whether V-Sync is enabled or not.
func _update_physics_steps_per_frame() -> void:
	var general_settings := load_settings("general")
	var ups: int = general_settings.ups
	var working_max_fps: int = general_settings.max_fps
	var is_v_sync_enabled: bool = general_settings.vsync
	if is_v_sync_enabled or working_max_fps == 0:
		working_max_fps = int(_get_screen_refresh_rate())
	# Added +2 at the end for leeway.
	Engine.max_physics_steps_per_frame = ceili(1.0 * ups / working_max_fps) + 2


## Returns the current refresh rate of the screen or 60.0 as a default if
## unable to find the refresh rate.
func _get_screen_refresh_rate() -> float:
	var refresh_rate := DisplayServer.screen_get_refresh_rate()
	if refresh_rate < 0:
		refresh_rate = 60.0
	return refresh_rate

extends ScrollContainer


@onready var _master_volume_label: Label = %MasterVolumeLabel
@onready var _master_volume_h_slider: HSlider = %MasterVolumeHSlider
@onready var _music_volume_label: Label = %MusicVolumeLabel
@onready var _music_volume_h_slider: HSlider = %MusicVolumeHSlider
@onready var _sfx_volume_label: Label = %SFXVolumeLabel
@onready var _sfx_volume_h_slider: HSlider = %SFXVolumeHSlider


func _ready() -> void:
	var audio_settings := ConfigHandler.load_settings("audio")
	
	_master_volume_label.text = _get_as_percent_str(audio_settings.master_volume)
	_master_volume_h_slider.value = audio_settings.master_volume
	_master_volume_h_slider.value_changed.connect(func(value: float) -> void:
		ConfigHandler.save_settings("audio", "master_volume", value)
		ConfigHandler.set_volume("Master", value)
		_master_volume_label.text = _get_as_percent_str(value)
	)
	
	_music_volume_label.text = _get_as_percent_str(audio_settings.music_volume)
	_music_volume_h_slider.value = audio_settings.music_volume
	_music_volume_h_slider.value_changed.connect(func(value: float) -> void:
		ConfigHandler.save_settings("audio", "music_volume", value)
		ConfigHandler.set_volume("Music", value)
		_music_volume_label.text = _get_as_percent_str(value)
	)
	
	_sfx_volume_label.text = _get_as_percent_str(audio_settings.sfx_volume)
	_sfx_volume_h_slider.value = audio_settings.sfx_volume
	_sfx_volume_h_slider.value_changed.connect(func(value: float) -> void:
		ConfigHandler.save_settings("audio", "sfx_volume", value)
		ConfigHandler.set_volume("SFX", value)
		_sfx_volume_label.text = _get_as_percent_str(value)
	)


## Returns [param value] as a percent and as a [String].
func _get_as_percent_str(value: float) -> String:
	return "%d%%" % (100 * value)

extends ScrollContainer

## Scroll directions for notes to move in.
const _SCROLL_DIRECTIONS: PackedStringArray = [
	"Down",
	"Up",
]

@onready var _scroll_direction_button: OptionButton = %ScrollDirectionButton
@onready var _scroll_speed_label: Label = %ScrollSpeedLabel
@onready var _scroll_speed_h_slider: HSlider = %ScrollSpeedHSlider
@onready var _audio_offset_spin_box: SpinBox = %AudioOffsetSpinBox


func _ready() -> void:
	var gameplay_settings := ConfigHandler.load_settings("gameplay")
	
	for direction in _SCROLL_DIRECTIONS:
		_scroll_direction_button.add_item(direction)
	var direction_str: String = gameplay_settings.scroll_direction
	_scroll_direction_button.selected = _SCROLL_DIRECTIONS.find(direction_str)
	_scroll_direction_button.item_selected.connect(func(idx: int) -> void:
		ConfigHandler.save_settings("gameplay", "scroll_direction",
				_SCROLL_DIRECTIONS[idx])
	)
	
	_scroll_speed_label.text = str(gameplay_settings.scroll_speed)
	_scroll_speed_h_slider.value = gameplay_settings.scroll_speed
	_scroll_speed_h_slider.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("gameplay", "scroll_speed", value)
		_scroll_speed_label.text = str(value)
	)
	
	_audio_offset_spin_box.value = gameplay_settings.audio_offset
	_audio_offset_spin_box.value_changed.connect(func(value: int) -> void:
		ConfigHandler.save_settings("gameplay", "audio_offset", value)
	)

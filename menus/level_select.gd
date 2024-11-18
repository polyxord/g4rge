extends Control


@export var _maps: Array[Map]

@onready var _v_box_container: VBoxContainer = %VBoxContainer


func _ready() -> void:
	var map_buttons: Array[Button] = []
	for map in _maps:
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = "[%s] %s - %s" % [map.game_mode, map.artist, map.song_name]
		button.pressed.connect(SceneHandler.goto_gameplay.bind(map))
		button.mouse_entered.connect(button.grab_focus)
		map_buttons.append(button)
		_v_box_container.add_child(button)
	
	var random_map_index := randi_range(0, map_buttons.size() - 1)
	map_buttons[random_map_index].grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene()

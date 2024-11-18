extends Control


@onready var _v_box_container: VBoxContainer = %VBoxContainer
@onready var _play_button: Button = %PlayButton
@onready var _settings_button: Button = %SettingsButton
@onready var _rat_button: Button = %RatButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	for child in _v_box_container.get_children():
		if child is not Button:
			continue
		
		var button := child as Button
		button.mouse_entered.connect(button.grab_focus)
	_rat_button.grab_focus()
	_rat_button.pressed.connect(
		SceneHandler.goto_scene.bind("res://menus/rat_menu.tscn", false)
	)
	_quit_button.pressed.connect(get_tree().quit)
	_play_button.pressed.connect(
		SceneHandler.goto_scene.bind("res://menus/level_select.tscn")
	)
	_settings_button.pressed.connect(
		SceneHandler.goto_scene.bind("res://menus/settings/settings_menu.tscn")
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

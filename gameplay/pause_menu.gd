class_name PauseMenu
extends ColorRect


@export var map_to_retry: Map

@onready var _v_box_container: VBoxContainer = %VBoxContainer
@onready var _resume_button: Button = %ResumeButton
@onready var _retry_button: Button = %RetryButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_resume_button.pressed.connect(func() -> void:
		visible = false
		get_tree().paused = false
	)
	_retry_button.pressed.connect(func() -> void:
		SceneHandler.goto_gameplay(map_to_retry, false)
		get_tree().paused = false
	)
	_quit_button.pressed.connect(func() -> void:
		SceneHandler.goto_scene("res://menus/rat_menu.tscn", false)
		get_tree().paused = false
	)
	for child in _v_box_container.get_children():
		if child is not Button:
			continue
		
		var button := child as Button
		button.mouse_entered.connect(button.grab_focus)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		get_tree().paused = visible
		if visible:
			_resume_button.grab_focus()

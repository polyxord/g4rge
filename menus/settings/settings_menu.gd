extends Control


@onready var _tab_container: TabContainer = %TabContainer


func _ready() -> void:
	_tab_container.get_tab_bar().grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneHandler.goto_scene()

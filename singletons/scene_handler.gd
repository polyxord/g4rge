## A singleton that manages scene switching.
## 
## @tutorial(Custom Scene Switcher): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#custom-scene-switcher
## @tutorial(Background Loading): https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
extends CanvasLayer

## Root node of the currently loaded main scene.
var _current_scene: Node
## Animation player that plays scene transitions.
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	_current_scene = get_tree().root.get_child(-1)
	hide()


## Switches the current scene to the scene at [param path].
## If [param fade_transition] is [code]true[/code], a fade transition will play
## when switching scenes.[br][br]
## [param transition_func] can be used to transfer data between scenes.
## Refer to the code of [method goto_gameplay] as an example.
func goto_scene(path: String = "res://menus/main_menu.tscn",
		fade_transition: bool = true,
		transition_func: Callable = func(): pass) -> void:
	ResourceLoader.load_threaded_request(path)
	if fade_transition:
		call_deferred("_fade_to_scene", path, transition_func)
	else:
		call_deferred("_change_to_scene", path, transition_func)


## Switches the current scene to gameplay playing the given map.
## If [param fade_transition] is true, the transition will fade into gameplay.
func goto_gameplay(map: Map, fade_transition: bool = true) -> void:
	var transition_func := func() -> void:
		if _current_scene is not Gameplay:
			return
		
		var gameplay := _current_scene as Gameplay
		gameplay.map = map
	goto_scene("res://gameplay/gameplay.tscn", fade_transition, transition_func)


## Switches the current scene to the scene at [param path] with a fade
## transition. Calls [param transition_func] when switching.[br][br]
## For transitionless scene switching, see [method _change_to_scene].
func _fade_to_scene(path: String, transition_func: Callable) -> void:
	show()
	_animation_player.play("fade")
	await _animation_player.animation_finished
	
	_change_to_scene(path, transition_func)
	_animation_player.play_backwards("fade")
	await _animation_player.animation_finished
	
	hide()


## Switches the current scene to the scene at [param path].
## Calls [param transition_func] when switching.[br][br]
## For scene switching with a fade transition, see [method _fade_to_scene].
func _change_to_scene(path: String, transition_func: Callable) -> void:
	_current_scene.free()
	var new_scene := ResourceLoader.load_threaded_get(path) as PackedScene
	_current_scene = new_scene.instantiate()
	transition_func.call()
	get_tree().root.add_child(_current_scene)
	# To make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = _current_scene

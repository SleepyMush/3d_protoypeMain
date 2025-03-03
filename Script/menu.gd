extends Control

@onready var Transition: AnimationPlayer = $AnimationPlayer
var LEVEL_MANAGER = preload("res://Scenes/Level_Manager.tscn")

func _on_play_pressed() -> void:
	Transition.play("Fade_OUT")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(LEVEL_MANAGER)

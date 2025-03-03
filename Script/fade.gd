class_name FadeTransition
extends Control
@onready var color_rect: ColorRect = $ColorRect

func fade_tween():
	var fade_in = get_tree().create_tween()
	fade_in.tween_property(color_rect,"self_modulate",Color.BLACK, 1.0)
	await fade_in.finished
	var Fade_out = get_tree().create_tween()
	Fade_out.tween_property(color_rect,"self_modulate",Color.WHITE,1.0)
	await Fade_out.finished
	color_rect.visible = false

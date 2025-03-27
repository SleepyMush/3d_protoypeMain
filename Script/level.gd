class_name Level
extends Node3D

signal level_complete(level_number : int)

@export var level_manager : LevelManager
@onready var navigation_region_3d: NavigationRegion3D 

func sample_random() -> Vector3:
	return NavigationServer3D.region_get_random_point(navigation_region_3d.get_rid(), 1, true) 

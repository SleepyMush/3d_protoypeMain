class_name Level
extends Node3D

signal level_complete

@export var navigation_region: NavigationRegion3D 

func sample_random() -> Vector3:
	return NavigationServer3D.region_get_random_point(navigation_region.get_rid(), 1, true) 

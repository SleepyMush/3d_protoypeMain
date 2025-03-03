class_name SpawnPoint
extends Marker3D

@export var spawned_scene : PackedScene
@export_file("*.tscn") var spawned_scene_path : String
@export var respawn_time : float = 2.0

enum SPAWNFLAGS{none = 0, start_spawn = 1, respawnable = 2}
@export_flags("start:1","respawnable:2") var flags = 3

func  _ready() -> void:
	if flags & SPAWNFLAGS.start_spawn :
		respawn(0.0)
	else :
		respawn(respawn_time)
	if flags & SPAWNFLAGS.respawnable :
		child_exiting_tree.connect(respawn.bind(respawn_time).unbind(1))

func spawn()-> Node: 
	if spawned_scene:
		return spawned_scene.instantiate()
	elif spawned_scene_path:
		var scene = load(spawned_scene_path)
		return scene.instantiate()
	return null

func respawn(time : float):
	await get_tree().create_timer(time).timeout
	var spawned_object = spawn()
	add_child(spawn())

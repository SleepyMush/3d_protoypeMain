extends Camera3D

@export var target : Node3D
signal update_camera_pos(ray, pos)

var Near: float = 0.001
var Far: float = 4000
var Size: float = 20

var Direction : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if &"control_basis" in target:
		target.control_basis = global_basis
	
	Direction = target.global_position - global_position 
	projection = Camera3D.PROJECTION_ORTHOGONAL
	set_orthogonal(Size, Near, Far)
	set_process(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position = event.global_position
		var ray = project_ray_origin(mouse_position)
		update_camera_pos.emit(-global_transform.basis.z, ray)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position =  target.global_position - Direction

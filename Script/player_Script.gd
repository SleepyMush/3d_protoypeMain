class_name Player
extends CharacterBody3D

#Misallanious
const control_adjustment : Vector2 = Vector2(1,1)
var sprint_time : float = 3.0
var sprint_time_remain : float = 0.0

#Player Variables
var current_speed : float = 5.0
var walking_speed : float = 5.0
var sprintSpeeds  : float = 10.0

#World Data
var direction = Vector3.ZERO
var control_basis : Basis
var jump_velocity : float = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const Waypoint = preload("res://Miscellaneous/Marker.tscn")
@onready var waypoint_holder: Node = $Waypoint_holder

@onready var progress_bar: ProgressBar = $OverLay/ProgressBar

@onready var health_node: Health_Node = $Health
@onready var health_bar: ProgressBar = $OverLay/Health_Bar
signal got_hit(damage_taken : float)

var collider
@onready var ray_cast: RayCast3D = $Node3D/RayCast3D

func _ready() -> void:
	health_bar.value = health_node.health
	progress_bar.max_value = sprint_time

func _process(delta: float) -> void:
	progress_bar.value = sprint_time_remain

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire"):
		if ray_cast.is_colliding():
			collider = ray_cast.get_collider()
			print(collider)
			if collider.get_parent() is EnemyBase:
				collider.get_parent().hit(10)

func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
		# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
	
	#current_speed = sprintSpeeds if Input.is_action_pressed("sprint") else walking_speed
	current_speed = walking_speed
	if Input.is_action_pressed("sprint"):
		if sprint_time_remain > 0.0:
			current_speed = sprintSpeeds
		if not velocity.is_zero_approx():
			sprint_time_remain -= delta
	if velocity.is_zero_approx():
			sprint_time_remain = clamp(sprint_time_remain + delta / 2.0, 0, sprint_time)
			
	
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (control_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed * control_adjustment.x
		velocity.z = direction.z * current_speed * control_adjustment.y
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	move_and_slide()


func _on_camera_3d_update_camera_pos(ray: Variant, pos: Variant) -> void:
	var height = pos.y - global_position.y
	var adjusted_pos : Vector3 = pos
	adjusted_pos.y = global_position.y
	var length = adjusted_pos.distance_to(global_position)
	
	var raylenght = pow(height, 2) + pow(length, 2)
	raylenght = sqrt(raylenght)
	var newlookatpos = pos + ray * raylenght
	newlookatpos.y = global_position.y
	if newlookatpos.distance_to(global_position) > 0.1:
		look_at(newlookatpos)
		orthonormalize()


func _on_timer_timeout() -> void:
	var w = Waypoint.instantiate()
	waypoint_holder.add_child(w)
	w.position = position

func hit(value: float) -> void:
	health_node.take_damage(value)
	print("Player ", value)
	emit_signal("got_hit", value)

func _on_health_died() -> void:
	pass
	#get_tree().paused = true

func _on_health_health_changed(health: float) -> void:
	health_bar.value = health

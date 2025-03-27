class_name EnemyBase
extends CharacterBody3D

var current_speed : float = 5.0
var chase_speed   : float = 8.0

var player : Player
var level : Level
@onready var target_position = Vector2()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer

@onready var range = $Waypoint_detector/CollisionShape3D.shape.size.length() / 2.0
var path : Array[Vector3]

enum ENEMY_STATE {IDLE, WANDER, CHASE, ENRAGE, DEAD}
var current_state : int = 0

func _ready() -> void:
	target_position = position
	current_state = ENEMY_STATE.IDLE

func _physics_process(delta: float) -> void:
	if not player :
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not path.is_empty() :
		navigation_agent.target_position = path[0]
	else :
		print("path_size " + str(path.size()))
		current_state = ENEMY_STATE.CHASE
		print("navigation_agent_target" + str(navigation_agent.target_position))
	
	match current_state:
		ENEMY_STATE.IDLE :
			velocity = Vector3.ZERO
		ENEMY_STATE.WANDER :
				if path.is_empty():
					velocity = Vector3.ZERO
				else :
					navigation_agent.get_next_path_position()
		ENEMY_STATE.ENRAGE :
			target_look()
		ENEMY_STATE.CHASE:
				var next_location : Vector3 = navigation_agent.get_next_path_position()
				var origin : Vector3 = global_position
				
				velocity = origin.direction_to(next_location).normalized() * current_speed
				
				if path.is_empty() :
					path.append(Vector3.ZERO)
				path.set(0, player.global_position)
				
				if player.global_position.distance_to(global_position) >= range:
					current_state = ENEMY_STATE.WANDER
		ENEMY_STATE.DEAD :
			velocity = Vector3.ZERO

	move_and_slide()

func target_look() -> void:
		var target_angle = Vector2(player.global_position.z, player.global_position.x).angle_to(Vector2(global_position.z, global_position.x))
		rotation.y = target_angle

func _Area_Entered(body: Node3D) -> void:
	if body is Player:
		player = body
		current_state = ENEMY_STATE.ENRAGE

func _Area_Exited(body: Node3D) -> void:
	if body is Player:
		player = body
		current_state = ENEMY_STATE.CHASE

func _on_waypoint_detector_area_entered(area: Area3D) -> void:
	if area.is_in_group("Waypoints"):
		path.append(area.position)

func _on_navigation_agent_3d_navigation_finished() -> void:
	if not path.is_empty() :
		path.pop_front()
	print("Target_reached")

func _on_timer_timeout() -> void:
	if path.is_empty():
		path.append(level.sample_random())

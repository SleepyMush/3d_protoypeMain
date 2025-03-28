class_name EnemyBase
extends CharacterBody3D

var current_speed : float = 5.0
var chase_speed   : float = 8.0

var player : Player

@onready var target_position = Vector2()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer

@onready var range: float = $Waypoint_detector/CollisionShape3D.shape.radius

var path : Array[Vector3] = []

enum ENEMY_STATE {IDLE, WANDER, CHASE, ENRAGE, DEAD}
var current_state : ENEMY_STATE = ENEMY_STATE.IDLE

@onready var health_node: Health_Node = $Health
var damage: float = 10.0
signal got_hit(damage_taken : float)

func _ready() -> void:
	navigation_agent.target_desired_distance = range* 0.25

func _physics_process(delta: float) -> void:
	if not player :
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var next_location : Vector3 = navigation_agent.get_next_path_position()
	match current_state:
		ENEMY_STATE.IDLE :
			velocity = Vector3.ZERO
		ENEMY_STATE.WANDER:
			velocity = (global_position.direction_to(next_location)).limit_length(global_position.distance_to(next_location))  * current_speed
		ENEMY_STATE.ENRAGE :
			target_look()
			player.hit(damage)
		ENEMY_STATE.CHASE:
			velocity = (global_position.direction_to(next_location)).limit_length(global_position.distance_to(next_location))  * current_speed
			
			path = [player.global_position]
			
			target_look()
			
			if player.global_position.distance_to(global_position) >= range:
				current_state = ENEMY_STATE.WANDER
		ENEMY_STATE.DEAD :
			velocity = Vector3.ZERO
			if health_node.health == 0:
				queue_free()
			
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
		match current_state:
			ENEMY_STATE.IDLE | ENEMY_STATE.WANDER:
				path.push_front(area.position)

func _on_navigation_agent_3d_navigation_finished() -> void:
	match current_state:
		ENEMY_STATE.WANDER:
			if not path.is_empty() :
				path.pop_front()
			current_state = ENEMY_STATE.IDLE
	print("Target_reached")

func _on_timer_timeout() -> void:
	match current_state:
		ENEMY_STATE.IDLE:
			if path.is_empty() :
				path.append(LevelManager.current.sample_random())
			current_state = ENEMY_STATE.WANDER
		ENEMY_STATE.WANDER:
			if path.is_empty() :
				current_state = ENEMY_STATE.IDLE
	if not path.is_empty():
		navigation_agent.target_position = path.get(0)
	print("Ping! %s" % [path])

func hit(value: float) -> void:
	health_node.take_damage(value)
	print("Enemy_damage ", value)
	
	emit_signal("got_hit", value)
	
	if health_node.health <= 0:
		current_state = ENEMY_STATE.DEAD

class_name EnemyBase
extends CharacterBody3D

var current_speed : float = 0.100
var chase_speed   : float = 1.0
var distance_chased_from : float = 0.100

var player : Player

@onready var timer: Timer = $Node/Timer

enum ENEMY_STATE {IDLE, ENRAGE, SEEK, DEAD}
var current_state : int = 0

func _ready() -> void:
	current_state = ENEMY_STATE.IDLE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match current_state:
		ENEMY_STATE.IDLE :
			pass
		ENEMY_STATE.ENRAGE :
			target_look()
		ENEMY_STATE.SEEK :
			global_position = lerp(global_position, player.global_position, current_speed * delta)
			if player.global_position.distance_to(global_position) >= distance_chased_from:
				current_speed = chase_speed
				if timer.is_stopped():
					timer.start()
			target_look()
		ENEMY_STATE.DEAD :
			pass
		
	move_and_slide()

func target_look() -> void:
		var target_angle = Vector2(player.global_position.z, player.global_position.x).angle_to_point(Vector2(global_position.z, global_position.x))
		rotation.y = target_angle

func _Area_Entered(body: Node3D) -> void:
	if body is Player:
		player = body
		current_state = ENEMY_STATE.ENRAGE


func _Area_Exited(body: Node3D) -> void:
	if body is Player:
		player = body
		current_state = ENEMY_STATE.SEEK

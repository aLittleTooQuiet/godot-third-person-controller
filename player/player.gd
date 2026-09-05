extends CharacterBody3D

@export var mouse_h_sensitivity: float = 0.02
@export var mouse_v_sensitivity: float = 0.02
@export var camera_tilt_min: float = -60.0
@export var camera_tilt_max: float = 30.0
@export var default_fov: float = 75.0
@export var fov_max: float = 80.0
@export var spring_arm_default_length: float = 5.0
@export var spring_arm_max_length: float = 8.0

@onready var pivot_horizontal: Node3D = %PivotHorizontal
@onready var pivot_vertical: Node3D = %PivotVertical
@onready var camera: Camera3D = %Camera3D
@onready var spring_arm: SpringArm3D = $CameraMount/PivotHorizontal/PivotVertical/SpringArm3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	pass
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()


func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		var cam_min_angle_rads := deg_to_rad(camera_tilt_min)
		var cam_max_angle_rads := deg_to_rad(camera_tilt_max)
		pivot_vertical.rotation.x += event.relative.y * mouse_v_sensitivity
		pivot_vertical.rotation.x = clampf(
			pivot_vertical.rotation.x,
			cam_min_angle_rads,
			cam_max_angle_rads
			)
			
		# Increase FOV as the camera looks up
		if pivot_vertical.rotation.x > 0:
			var fov_max_ratio = 1 - (cam_max_angle_rads - pivot_vertical.rotation.x)
			camera.fov = default_fov + ((fov_max - default_fov) * fov_max_ratio)
		# Increase camera distance as camera looks down
		elif pivot_vertical.rotation.x < 0:
			camera.fov = default_fov
			var fov_min_ratio = 1 - (pivot_vertical.rotation.x - cam_min_angle_rads)
			print(fov_min_ratio)
			if fov_min_ratio > 0:
				spring_arm.spring_length = spring_arm_default_length + ((spring_arm_max_length - spring_arm_default_length) * fov_min_ratio)
			else:
				spring_arm.spring_length = spring_arm_default_length
		pivot_horizontal.rotation.y += -event.relative.x * mouse_h_sensitivity
		
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cancel'):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

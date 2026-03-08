extends CharacterBody3D

#--- Constants ---
const BASE_SPEED := 10.0
const ROTATION_SPEED := 0.09
const JUMP_VELOCITY := 10.0
const CAMERA_PIVOT_HEIGHT := 3.0
const CAMERA_PITCH_MIN := -45.0
const CAMERA_PITCH_MAX := 70.0
const ANIM_BLEND_PATH := "parameters/BlendSpace1D/blend_position"

#--- Exports--- Note: Incase I need it in future
@export var max_energy: float = 100.0
@export var energy_drain_rate: float = 2.0  # per second
@export var starvation_damage: float = 5.0  # damage per second when starving

#--- Node Refrences --- Note: All of there are nodes in player_v2 scene
@onready var camera_pivot: Node3D = $"../CameraPivot"
@onready var first_person_camera: Camera3D = $"../CameraPivot/Camera3D"
@onready var third_person_camera: Camera3D = $"../CameraPivot/SpringArm3D/Camera3D"
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var ray_cast_3d: RayCast3D = $"../CameraPivot/Camera3D/RayCast3D"

#--- State --- Note: Anything that's the player current condition at any time goes here
var is_first_person := true
var mouse_sensitivity := 0.002
var speed := BASE_SPEED
var selected: int = 0
var direction := Vector3.ZERO
var current_energy: float = 100.0


signal energy_changed(new_value: float, max_value: float)


func _ready() -> void: # Makes the mouse curser dissapered
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_key_input(_event: InputEvent) -> void: # Quits program on esc key
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void: #execute func by key press
	if event is InputEventMouseMotion:
		_handle_mouse_look(event)
	_handle_perspective_toggle()
	_handle_jump()
	_handle_movement()
	_handle_block_interaction()


func _physics_process(delta: float) -> void: # executes functions by physics or "reactions"
	_apply_gravity(delta)
	_handle_camera_pivot_follow()
	_handle_body_rotation()
	_update_animation()
	_drain_energy(delta)
	move_and_slide()


#--- Public Helpers --- Note: This is where public functions get extablish, so that State can execute them

func eat(amount: float) -> void: #There are no items the player can eat at this moment
	current_energy = min(current_energy + amount, max_energy)
	energy_changed.emit(current_energy, max_energy)

#--- Private Helpers --- Note: This is where private functions get extablish, so that State can execute them

func _handle_perspective_toggle() -> void: #Allows the change of POV with the key "V"
	if Input.is_action_just_pressed("POV"):
		is_first_person = !is_first_person
		first_person_camera.current = is_first_person
		third_person_camera.current = !is_first_person


func _handle_camera_pivot_follow() -> void: # This sets the camera pivot on players position
	camera_pivot.global_position = global_position + Vector3(0, CAMERA_PIVOT_HEIGHT, 0)


func _handle_mouse_look(event: InputEventMouseMotion) -> void: # turns the camera to mouse movement
	camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity
	camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x,
		deg_to_rad(CAMERA_PITCH_MIN),
		deg_to_rad(CAMERA_PITCH_MAX)
	)


func _apply_gravity(delta: float) -> void: # apply gravity to the player
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_jump() -> void: # Lets player jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func _handle_movement() -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0.0
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0


func _handle_body_rotation() -> void: #This helps the player body rotate and work with the camera
	if direction != Vector3.ZERO:
		var target_angle := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED)


func _handle_block_interaction() -> void: #Lets player place and destroy blocks
	if not ray_cast_3d.is_colliding():
		return

	var collider := ray_cast_3d.get_collider()

	if Input.is_action_just_pressed("left_click"):
		if collider.has_method("destroy_block"):
			var hit_pos := ray_cast_3d.get_collision_point() - ray_cast_3d.get_collision_normal()
			collider.destroy_block(hit_pos)

	if Input.is_action_just_pressed("right_click"):
		if collider.has_method("place_block"):
			var place_pos := (ray_cast_3d.get_collision_point() + ray_cast_3d.get_collision_normal()).round()
			collider.place_block(place_pos, selected)


func _drain_energy(delta: float) -> void: 
	if direction != Vector3.ZERO:
		current_energy -= energy_drain_rate * delta
		current_energy = clamp(current_energy, 0.0, max_energy)
		energy_changed.emit(current_energy, max_energy)
	
	if current_energy == 0.0:
		_take_starvation_damage(delta)


func _take_starvation_damage(delta: float) -> void:
	# Hook into your existing health system here
	print("Starving! Taking damage: ", starvation_damage * delta)


func _update_animation() -> void: #lets the player model's animation know when player is moving to apply animations.
	anim_tree.set(ANIM_BLEND_PATH, velocity.length() / speed)

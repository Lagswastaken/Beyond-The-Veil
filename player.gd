extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D

var health = 3

var objects_collected = 0

@onready var ray =$Camera3D/RayCast3D
@onready var interaction_notify = $Control/InteractionNotify
@onready var collection_tracker = $Control/MarginContainer/CollectionTracker

const SPEED = 5.0
const JUMP_VELOCITY = 6.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 60.0

func check_ray_hit():
	if ray.is_colliding():
		if ray.get_collider().is_in_group("Pickup"):
			interaction_notify.visible = true
		if Input.is_action_just_pressed("Use"):
			ray.get_collider().queue_free()
			objects_collected += 1
			collection_tracker.text = "Mysterious Objects: " + str(objects_collected) + " /8"
	else:
		interaction_notify.visible = false


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	elif Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	check_ray_hit()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

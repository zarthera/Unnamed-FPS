extends KinematicBody

# Getting Keyboard hotkeys 1-9
var hotkeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

export var mouse_sens = 0.5

# Refences to other nodes
onready var camera = $Camera
onready var gun_cam = $Camera/ViewportContainer/Viewport/GunCam
onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager
onready var weapon_manager = $Camera/WeaponManager

var dead = false

#Initial camera position and the position the camera leans to
export var camera_base_position : Vector3
export var camera_lean_position : Vector3

#The amount we interpolate our lean by
var lean_lerp = 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	health_manager.init()
	health_manager.connect("dead", self, "kill")
	weapon_manager.init($Camera/FirePoint, [self])

func _process(delta):
	if Input.is_action_just_pressed("tilde"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if dead:
		return
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
	weapon_manager.attack(Input.is_action_pressed("attack"))
	character_mover.set_move_vec(move_vec)
	
	handle_leaning(delta)
	return_cam_to_base(delta)
	
	gun_cam.global_transform = camera.global_transform

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	if event is InputEventKey and event.pressed:
		if event.scancode in hotkeys:
			weapon_manager.switch_to_weapon_slot(hotkeys[event.scancode])
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_next_weapon()
		if event.button_index == BUTTON_WHEEL_UP:
			weapon_manager.switch_to_last_weapon()

func hurt(damage, dir):
	health_manager.hurt(damage, dir)

func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	character_mover.freeze()

func handle_leaning(delta):
	var lean_limit = camera_lean_position.x
	var action_strength
	action_strength = (Input.get_action_strength("move_right")) - Input.get_action_strength("move_left")
	
	if action_strength != 0:
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 5.0 * ((lean_limit + 0.25) * -action_strength), lean_lerp * delta)

func return_cam_to_base(delta):
	if (!Input.is_action_pressed("move_right") and ! Input.is_action_pressed("move_left")):
		if camera.transform.origin.x != 0 or camera.rotation_degrees.z != 0:
			camera.transform.origin = camera.transform.origin.linear_interpolate(camera_base_position, lean_lerp * delta)
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 0.0, lean_lerp * delta)



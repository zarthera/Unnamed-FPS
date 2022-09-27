extends KinematicBody


export var mouse_sens = 0.5

onready var camera = $Camera
onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager

var dead = false

export var camera_base_position : Vector3
export var camera_lean_position : Vector3

var lean_lerp = 5
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	health_manager.init()
	health_manager.connect("dead", self, "kill")

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
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
	character_mover.set_move_vec(move_vec)
	
	handle_leaning(delta)
	return_cam_to_base(delta)
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

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

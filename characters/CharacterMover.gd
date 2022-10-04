extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 4
export var max_speed = 25
var drag = 0.0
export var jump_force = 30
export var gravity = 60

var pressed_jump = false
var move_vec : Vector3
var velocity : Vector3
var snap_vec : Vector3
export var ignore_rotation = false

signal movement_info

var frozen = false

var coyote_jump = true
func _ready():
	drag = float(move_accel) / max_speed

func init(_body_to_move: KinematicBody):
	body_to_move = _body_to_move

func jump():
	pressed_jump = true

func set_move_vec(_move_vec: Vector3):
	move_vec = _move_vec.normalized()

func _physics_process(delta):
	if frozen:
		return
	var cur_move_vec = move_vec
	if !ignore_rotation:
		cur_move_vec = cur_move_vec.rotated(Vector3.UP, body_to_move.rotation.y)
	velocity += move_accel * cur_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
	var grounded = body_to_move.is_on_floor()
	if !body_to_move.is_on_floor():
		coyoteTime()
		
	if grounded:
		coyote_jump = true
		if pressed_jump:
			velocity.y = jump_force
		velocity.y = -0.01
		
	if Input.is_action_pressed("jump"):
		pressed_jump = true
		rememberJumpTime()
		if coyote_jump:
			velocity.y = jump_force
		
	if pressed_jump:
		coyote_jump = false
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN
		
	emit_signal("movement_info", velocity, grounded)

func freeze():
	frozen = true

func unfreeze():
	frozen = false

func coyoteTime():
	yield(get_tree().create_timer(.2), "timeout")
	coyote_jump = false
	
func rememberJumpTime():
	yield(get_tree().create_timer(.2), "timeout")
	pressed_jump = false



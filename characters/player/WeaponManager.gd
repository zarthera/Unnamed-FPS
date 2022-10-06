extends Spatial


enum WEAPON_SLOTS {MELEE, PISTOL, SHOTGUN}
var slots_unlocked = {
	WEAPON_SLOTS.MELEE: true,
	WEAPON_SLOTS.PISTOL: true,
	WEAPON_SLOTS.SHOTGUN: true,
	#WEAPON_SLOTS.ROCKET: true,
}

onready var weapons = $Weapons.get_children()
var current_slot = 0
var current_weapon = null
var fire_point : Spatial 
var bodies_to_exclude : Array = []

var mouse_move_x
var mouse_move_y
var sway_threshold_x = 1
var sway_threshold_y = 1
var sway_lerp = 2

export var sway_left : Vector3
export var sway_right : Vector3
export var sway_up : Vector3
export var sway_down : Vector3
export var sway_normal : Vector3

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _bodies_to_exclude)
	switch_to_weapon_slot(WEAPON_SLOTS.MELEE)
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_move_x = -event.relative.x
		mouse_move_y = -event.relative.y

func _process(delta):	
	if mouse_move_x != null:
		if mouse_move_x > sway_threshold_x:
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_left, sway_lerp * delta)
		elif mouse_move_x < -sway_threshold_x:
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_right, sway_lerp * delta)
		else: 
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_normal, sway_lerp * delta)
		mouse_move_x = 0
	if mouse_move_y != null:
		if mouse_move_y > sway_threshold_y:
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_up, sway_lerp * delta)
		elif mouse_move_y < -sway_threshold_y:
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_down, sway_lerp * delta)
		else:
			for weapon in weapons:
				weapon.rotation = weapon.rotation.linear_interpolate(sway_normal, sway_lerp * delta)
		mouse_move_y = 0
		
		for weapon in weapons:
			if weapon.name == "Melee" and Input.is_action_just_pressed("attack"):
				$Weapons/Melee/AnimationPlayer.play("Attack")
				

func attack(attack_input_pressed: bool):
	if current_weapon.has_method("attack"):
		current_weapon.attack(attack_input_pressed)

func switch_to_next_weapon():
	#If index is higher than the slot index it will wrap around to 0
	current_slot = (current_slot + 1) % slots_unlocked.size()
	if !slots_unlocked[current_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(current_slot)

func switch_to_last_weapon():
	#Like switch_to_next_weapon() except it wraps number to be positive
	current_slot = posmod((current_slot - 1), slots_unlocked.size())
	if !slots_unlocked[current_slot]:
		switch_to_last_weapon()
	else:
		switch_to_weapon_slot(current_slot)

func switch_to_weapon_slot(slot_index: int):
	if slot_index < 0 or slot_index >= slots_unlocked.size():
		return
	if !slots_unlocked[current_slot]:
		return
	disable_all_weapons()
	current_weapon = weapons[slot_index]
	print(current_weapon.name)
	if current_weapon.has_method("set_active"):
		current_weapon.set_active()
	else:
		current_weapon.show()

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()


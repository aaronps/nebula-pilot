
extends Area2D
#extends KinematicBody2D

signal ship_engine_on
signal ship_engine_off
signal ship_died

const HORIZ_MARGIN = 16
const VERT_MARGIN = 16

export var max_speed = 240
export var shield_enabled = true

var area_lock = true

#export var accel_force = 800
#export var break_force = 400

var x_min = HORIZ_MARGIN
var x_max = 480 - HORIZ_MARGIN
var y_min = VERT_MARGIN
var y_max = 800 - VERT_MARGIN

#var zone_rect = Rect2(x_min, y_min, x_max - x_min, y_max - y_min)

const AXIS_MIN = 0.15

const BSHIP_UP    = 1
const BSHIP_DOWN  = 2
const BSHIP_LEFT  = 4
const BSHIP_RIGHT = 8

var button_flags = 0
var diddie = false

var input_dir_v_button = false
var input_dir_h_button = false


var input_dir = Vector2()
var input_speed = 0

onready var left_thrust = get_node("left_thrust")
onready var right_thrust = get_node("right_thrust")
onready var shield = get_node("Shield")

var engine_on = false
var engine_sound_id = -1
var velocity = Vector2()

func _die():
	queue_free()


func _ready():
	if not shield_enabled:
		shield.disable()
	
	var vsize = get_viewport_rect().size
	x_max = vsize.width - x_min
	y_max = vsize.height - y_min
	
	set_fixed_process(true)

func _exit_tree():
	if engine_on:
		pause_sounds()

func clear_input_forces():
	input_speed = 0
	button_flags = 0

func set_input_force_y(value):
	var vel = input_dir * input_speed
	vel.y = value
	input_speed = min(1, vel.length())
	input_dir = vel.normalized()

func set_input_force_x(value):
	var vel = input_dir * input_speed
	vel.x = value
	input_speed = min(1, vel.length())
	input_dir = vel.normalized()

func set_input_force(direction, force):
	input_dir = direction
	input_speed = force

func clear_input_force():
	input_speed = 0

func set_input_up(state):
	if state:
		button_flags |= BSHIP_UP
	else:
		button_flags &= ~BSHIP_UP

func set_input_down(state):
	if state:
		button_flags |= BSHIP_DOWN
	else:
		button_flags &= ~BSHIP_DOWN

func set_input_left(state):
	if state:
		button_flags |= BSHIP_LEFT
	else:
		button_flags &= ~BSHIP_LEFT

func set_input_right(state):
	if state:
		button_flags |= BSHIP_RIGHT
	else:
		button_flags &= ~BSHIP_RIGHT

func _fixed_process(delta):
	
	var opos = get_pos()
	
	if engine_on:
		if button_flags == 0:
			velocity = input_dir * (input_speed * max_speed)
		else:
			var move_dir = Vector2(input_dir.x, input_dir.y)
			if button_flags & BSHIP_UP:
				move_dir.y = -1
			elif button_flags & BSHIP_DOWN:
				move_dir.y = 1
				
			if button_flags & BSHIP_LEFT:
				move_dir.x = -1
			elif button_flags & BSHIP_RIGHT:
				move_dir.x = 1
			
			velocity = move_dir * max_speed
		
		if (opos.y <= y_min and velocity.y < 0) or (opos.y >= y_max and velocity.y > 0):
			velocity.y = 0
		
		if (opos.x <= x_min and velocity.x < 0) or (opos.x >= x_max and velocity.x > 0):
			velocity.x = 0
		
		left_thrust.set_initial_velocity(velocity/2)
		right_thrust.set_initial_velocity(velocity/2)
	
	var m = velocity * delta
	if ! diddie and area_lock:
		set_pos(Vector2(clamp(opos.x + m.x, x_min, x_max), clamp(opos.y + m.y, y_min, y_max)))
		#move_to(Vector2(clamp(opos.x + m.x, x_min, x_max), clamp(opos.y + m.y, y_min, y_max)))
		
		#if is_colliding():
		#	var c = get_collider()
		#	c._on_collided()
		#	_on_collided()
	else:
		set_pos(Vector2(opos.x + m.x, opos.y + m.y))
		#move(m)


func _on_collided():
	if not diddie:
		diddie = true
		
		emit_signal("ship_died")
		
		get_node("AnimationPlayer").play("Explode")
		stopEngine()
		velocity /= 2
		
		# only one ball explodes
		return true
	
	# other balls doesn't explode
	return false

func xsetThrust(yesno):
	left_thrust.set_emitting(yesno)
	right_thrust.set_emitting(yesno)

func startEngine():
	if not engine_on:
		engine_on = true
		xsetThrust(true)
		engine_sound_id = gSoundPlayer.play("thurst2")
		emit_signal("ship_engine_on")

func stopEngine():
	if engine_on:
		engine_on =false
		xsetThrust(false)
		gSoundPlayer.stop(engine_sound_id)
		emit_signal("ship_engine_off")

func enable_shield():
	if not shield_enabled:
		shield_enabled = true
		shield.enable()

func disable_shield():
	if shield_enabled:
		shield_enabled = false
		shield.disable()

func set_viewsize(s):
	x_max = s.width - x_min
	y_max = s.height - y_min

func pause_sounds():
	gSoundPlayer.stop(engine_sound_id)

func resume_sounds():
	engine_sound_id = gSoundPlayer.play("thurst2")

func _on_Ship_body_enter( body ):
	if _on_collided():
		body._on_collided()
		call_deferred("set_enable_monitoring", false)
	


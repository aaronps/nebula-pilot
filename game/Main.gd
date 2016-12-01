

extends Node

export var debril_count = 30
export var debril_max_speed = 240
export var attack_radius = Vector2(80,80)
export var max_ship_speed = 240

var menu_opened = false

const SHIP_SAFE_WIDTH = 48
const SHIP_SAFE_HEIGHT = 48

var VIEW_WIDTH = 480
var VIEW_HEIGHT = 800

var VIEW_CENTER = Vector2(VIEW_WIDTH/2, VIEW_HEIGHT/2)

var DEBRIL_GEN_AREA_WIDTH = VIEW_WIDTH - SHIP_SAFE_WIDTH
var DEBRIL_GEN_AREA_HEIGHT= VIEW_HEIGHT- SHIP_SAFE_HEIGHT

const MIN_JOYSTICK_DIS = 0.2
const PI2 = 3.1415926 * 2


onready var player_start_pos = get_node("logic/player_start_pos").get_pos()

var Ship = preload("res://ship/Ship.tscn")
var Debril = preload("res://debril/Debril.tscn")
var DebrilClass = preload("res://debril/Debril.gd")

var player
var alive_time = 0.0

# mjoy is mouse joystick, click to set center, drag to move it.
var mjoy_ismoving = false
var mjoy_center = Vector2()
var mjoy_pos = Vector2()
onready var mjoy = get_node("ui/MJoy")
onready var mjoypin = get_node("ui/MJoy/pin")
const MJOY_RADIUS = 50

const STATE_NOT_STARTED = 0
const STATE_PLAYING = 1
const STATE_DEAD = 2
const STATE_ANIMATING = 3
const STATE_PLAYING_PAUSED = 4
const STATE_PLAYING_CREDITS = 5
const STATE_DEAD_CREDITS = 6

#export(int, "Not Started", "Playing", "Dead", "Animating", "Playing Paused", "Playing Credits")
var state = STATE_NOT_STARTED

onready var highscores_panel = get_node("ui/highscores")
onready var bgstars = get_node("game/bgstars")
onready var sprites_layer = get_node("game/sprites")
onready var label_time = get_node("ui/label_time")
onready var animationplayer = get_node("AnimationPlayer")
onready var ui_animationplayer = get_node("ui/AnimationPlayer")
onready var streamplayer = get_node("StreamPlayer")


# Possible values are: "Android", "BlackBerry 10", "Flash", "Haiku", "iOS", "HTML5", "OSX", "Server", "Windows", "WinRT", "X11"
var is_mobile = ["Android", "iOS"].find(OS.get_name()) >= 0

func _ready():
	randomize()
	init_random()
	
#	var vp = get_tree().get_root()
	var vp = get_node("/root")
	var vpsize = vp.get_visible_rect().size
	
	set_view_area(vpsize)
	
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	
	get_tree().set_auto_accept_quit(false)
	
	start_level()

func _notification(what):
#	print("NoTIFICATION:",what)
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if state == STATE_PLAYING and is_mobile:
			_on_MenuButton_pressed()
		else:
			get_tree().quit()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if state == STATE_PLAYING:
			_on_MenuButton_pressed()
#	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#		print("--> focus out")
#	elif what == Node.NOTIFICATION_PAUSED:
#		print("--> paused")
#	elif what == Node.NOTIFICATION_UNPAUSED:
#		print("--> unpaused")

func set_view_area(view_area):
	print("new size is: ", view_area)
	
	VIEW_WIDTH = view_area.width
	VIEW_HEIGHT = view_area.height
	
	VIEW_CENTER = view_area/2
	
	DEBRIL_GEN_AREA_WIDTH = VIEW_WIDTH
	DEBRIL_GEN_AREA_HEIGHT= VIEW_HEIGHT
	
	bgstars.set_viewsize(view_area)
	
	var debril_area = get_node("logic/Area2D")
	var debril_area_shape = debril_area.get_shape(0)
	
	debril_area.set_pos(VIEW_CENTER)
	debril_area_shape.set_extents(VIEW_CENTER)

# @note when start_level starts, the player can't see anything
func start_level():
	state = STATE_ANIMATING
	bgstars.start_loading_background()
	
	streamplayer.prepare_next()
	
	_remove_debrils()
	init_player()
	init_debrils(debril_count)
	
	while not bgstars.finish_loading_background():
		yield(get_tree(), "idle_frame")
	
	animationplayer.queue("enter_readytostart")
	yield(animationplayer, "finished")
	state = STATE_NOT_STARTED

func init_player():
	player = Ship.instance()
	player.max_speed = max_ship_speed
	player.set_pos(player_start_pos)
	player.enable_shield()
	player.set_viewsize(Vector2(VIEW_WIDTH, VIEW_HEIGHT))
	player.connect("ship_engine_on", self, "_on_ship_engine_on")
	player.connect("ship_engine_off", self, "_on_ship_engine_off")
	player.connect("ship_died", self, "_on_ship_died")
	alive_time = 0.0
	sprites_layer.add_child(player)

func init_debrils(count):
	for i in range(count):
		init_debril()

func init_debril():
#	var angle = randf() * PI2
#	var dist = rand_range(dist_start, dist_max)
#	
#	var vangle = Vector2(cos(angle) * dist, sin(angle) * dist)
	var pos = Vector2(random_float() * DEBRIL_GEN_AREA_WIDTH, random_float() * DEBRIL_GEN_AREA_HEIGHT) - VIEW_CENTER
	if abs(pos.x) <= SHIP_SAFE_WIDTH and abs(pos.y) <= SHIP_SAFE_HEIGHT:
		pos += Vector2(sign(pos.x) * SHIP_SAFE_WIDTH, sign(pos.y) * SHIP_SAFE_HEIGHT)
	pos += VIEW_CENTER
	
	var d = Debril.instance()
	d.set_pos(pos)
	#d.set_pos(player_start_pos + vangle)
	
	var dirangle = random_float() * PI2
	var speed = random_float() * (debril_max_speed/2) + (debril_max_speed/2)
	
	d.set_linear_velocity(Vector2(cos(dirangle) * speed, sin(dirangle) * speed))
	
	sprites_layer.add_child(d)

func _remove_debrils():
	for i in range(sprites_layer.get_child_count()):
		var d = sprites_layer.get_child(i)
		if d extends DebrilClass:
			d._die_alone()

func _input(event):
	# this is needed because if the mouse or finger goes over the pause button, the events won't go to "unhandled"
	# and we need at least the movement
	if mjoy_ismoving and (event.type == InputEvent.MOUSE_MOTION):
		_unhandled_input(event)

func _unhandled_input(event):
	
#	print("Event from _input: ", event)
	if event.is_echo():
		return
	
	if state == STATE_NOT_STARTED:
		var shall_start = false
		if event.type == InputEvent.JOYSTICK_MOTION:
			shall_start = abs(event.value) > 0.5 and ( event.is_action("ship_up") or event.is_action("ship_left") )
		else:
			shall_start = event.is_pressed() and (
							event.is_action("ui_accept")
						 or event.is_action("ship_mousemove")
						 or event.is_action("ship_left")
						 or event.is_action("ship_right")
						 or event.is_action("ship_up")
						 or event.is_action("ship_down")
						)
		
		if shall_start:
			get_tree().set_input_as_handled()
			player.startEngine()
			if menu_opened:
				ui_animationplayer.queue("close_menu")
		elif event.is_action("pause") and event.is_pressed():
			_on_MenuButton_pressed()
	
	elif state == STATE_PLAYING_PAUSED:
		var shall_start = false
		if event.type == InputEvent.JOYSTICK_MOTION:
			shall_start = abs(event.value) > 0.5 and ( event.is_action("ship_up") or event.is_action("ship_left") )
		else:
			shall_start = event.is_pressed() and (
					        event.is_action("ship_mousemove")
						 or event.is_action("ship_left")
						 or event.is_action("ship_right")
						 or event.is_action("ship_up")
						 or event.is_action("ship_down")
						 or event.is_action("pause")
						)
		
		if shall_start:
			get_tree().set_input_as_handled()
			_on_MenuButton_pressed()
			
			# note, if it is pause, it will be repaused on next if... better return now
			if event.is_action("pause"):
				return;
				
	elif state == STATE_PLAYING_CREDITS:
		var shall_start = event.is_pressed() and (
							event.is_action("ui_accept")
						 or event.is_action("ship_mousemove")
						 or event.is_action("ship_left")
						 or event.is_action("ship_right")
						 or event.is_action("ship_up")
						 or event.is_action("ship_down")
						)
		if shall_start:
			get_tree().set_input_as_handled()
			state = STATE_ANIMATING
			animationplayer.queue("hide_credits")
			yield(animationplayer, "finished")
			state = STATE_PLAYING_PAUSED
			
	elif state == STATE_DEAD:
		
		var shall_start = event.is_pressed() and (
							event.is_action("ui_accept")
						 or event.is_action("ship_mousemove")
						 or event.is_action("ship_left")
						 or event.is_action("ship_right")
						 or event.is_action("ship_up")
						 or event.is_action("ship_down")
						)
		
		if shall_start:
			get_tree().set_input_as_handled()
			if menu_opened:
				ui_animationplayer.queue("close_menu")
			
			state = STATE_ANIMATING
			animationplayer.queue("restart_from_die")
			yield(animationplayer, "finished")
			start_level()
			
	elif state == STATE_DEAD_CREDITS:
		var shall_start = event.is_pressed() and (
							event.is_action("ui_accept")
						 or event.is_action("ship_mousemove")
						 or event.is_action("ship_left")
						 or event.is_action("ship_right")
						 or event.is_action("ship_up")
						 or event.is_action("ship_down")
						)
		if shall_start:
			get_tree().set_input_as_handled()
			state = STATE_ANIMATING
			animationplayer.queue("hide_credits")
			yield(animationplayer, "finished")
			state = STATE_DEAD
		
	# note: there is no 'elif' here because we need to take the input parameters in case state changed to playing.
	if state == STATE_PLAYING:
		
		if event.type == InputEvent.JOYSTICK_MOTION:
			#only need to check for one axis of each
			if event.is_action("ship_up"):
				get_tree().set_input_as_handled()
				if abs(event.value) >= MIN_JOYSTICK_DIS:
					player.set_input_force_y(event.value)
				else:
					player.set_input_force_y(0)
			elif event.is_action("ship_left"):
				get_tree().set_input_as_handled()
				if abs(event.value) >= MIN_JOYSTICK_DIS:
					player.set_input_force_x(event.value)
				else:
					player.set_input_force_x(0)
		
		elif event.type == InputEvent.MOUSE_MOTION and mjoy_ismoving:
			get_tree().set_input_as_handled()
			if mjoy_pos != event.pos:
				mjoy_pos = event.pos
				var move_vector = mjoy_pos - mjoy_center
				var move_vector_norm = move_vector.normalized()
				var speed = min(move_vector.length(), MJOY_RADIUS)/MJOY_RADIUS
				
				mjoypin.set_pos(move_vector_norm * (speed * MJOY_RADIUS))
				player.set_input_force(move_vector_norm, speed)
				
		elif event.is_action("ship_mousemove"):
			get_tree().set_input_as_handled()
			# Explanation:
			#	if it is a begin mouse move and is not moving now -> begin move, not the and is a nested if
			#   otherwise (the action is not pressed anymore) but we think is moving, cancel it
			if Input.is_action_pressed("ship_mousemove"):
				if not mjoy_ismoving:
					mjoy_ismoving = true
					if event.type == InputEvent.MOUSE_BUTTON:
						mjoy_center = event.pos
						mjoy.show()
					else:
						mjoy_center = get_viewport().get_mouse_pos()
					
					mjoy_pos = mjoy_center
					mjoy.set_pos(mjoy_center)
					mjoy.show()
			elif mjoy_ismoving:
				mjoy_ismoving = false
				mjoy.hide()
				player.input_dir.x = 0
				player.input_dir.y = 0
				player.input_speed = 0
		elif event.is_action("ship_up"):
			get_tree().set_input_as_handled()
			player.set_input_up(Input.is_action_pressed("ship_up"))
		elif event.is_action("ship_down"):
			get_tree().set_input_as_handled()
			player.set_input_down(Input.is_action_pressed("ship_down"))
		elif event.is_action("ship_left"):
			get_tree().set_input_as_handled()
			player.set_input_left(Input.is_action_pressed("ship_left"))
		elif event.is_action("ship_right"):
			get_tree().set_input_as_handled()
			player.set_input_right(Input.is_action_pressed("ship_right"))
		elif event.is_action("pause"):
			if event.is_pressed():
				pause_game()
				ui_animationplayer.play("open_menu")



func _on_ship_engine_on():
	bgstars.setSlowMode(false)
	if state == STATE_NOT_STARTED:
		state = STATE_PLAYING
		player.disable_shield()
		streamplayer.start_play()

func _on_ship_engine_off():
	bgstars.setSlowMode(true)

func _on_ship_died():
	mjoy_ismoving = false
	mjoy.hide()
	mjoypin.set_pos(Vector2(0,0))
	# need to set the state here to other than PLAYING because it might be possible that between
	# now and the animation start, there could be a "process" loop and the visual time would differ
	# from the highscores time, so, set here to animating to avoid problems.
	# other solution would be to update the panel from the animation....
	state = STATE_ANIMATING
	player = null
	highscores_panel.add_score(alive_time)
	
	animationplayer.queue("on_player_died")
	yield(animationplayer, "finished")
	state = STATE_DEAD

func _on_Area2D_body_exit( body ):
	if not body extends DebrilClass:
		return
	
	if ! body.died: # so it did really go out of the border
		if state == STATE_DEAD or player == null:
			body.queue_free()
		else:
			var p = body.get_pos()
			
			if p.x < 0:
				p.x = VIEW_WIDTH - p.x
				p.y = random_float() * VIEW_HEIGHT
			elif p.x > VIEW_WIDTH:
				p.x = VIEW_WIDTH - p.x
				p.y = random_float() * VIEW_HEIGHT
			elif p.y < 0:
				p.y = VIEW_HEIGHT - p.y
				p.x = random_float() * VIEW_WIDTH
			else:
				p.y = VIEW_HEIGHT - p.y
				p.x = random_float() * VIEW_WIDTH
			
			body.set_pos(p)
			
			var speed = random_float() * (debril_max_speed/2) + (debril_max_speed/2)
			var v = (player.get_pos() - attack_radius + (random_float() * (attack_radius * 2))) - body.get_pos()
			body.set_linear_velocity(v.normalized() * speed)

func _process(delta):
	if state == STATE_PLAYING:
		alive_time += delta
		
		var secs = floor(alive_time)
		var ms = floor((alive_time - secs) * 1000)
		
		label_time.set_text(str(secs, ".", ms).pad_decimals(3))
	


func pause_game():
	get_tree().set_pause(true)
	state = STATE_PLAYING_PAUSED
	mjoy_ismoving = false
	mjoy.hide()
	player.clear_input_forces()
	player.pause_sounds();

func resume_game():
	get_tree().set_pause(false)
	player.resume_sounds()
	state = STATE_PLAYING
	

func _on_MenuButton_pressed():
	if state == STATE_PLAYING:
		pause_game()
		ui_animationplayer.play("open_menu")
	elif state == STATE_PLAYING_PAUSED:
		resume_game()
		ui_animationplayer.play("close_menu")
	else:
		if menu_opened:
			ui_animationplayer.queue("close_menu")
		else:
			ui_animationplayer.queue("open_menu")

func _on_MusicButton_toggled( pressed ):
	if pressed:
		UserPrefs.set_music_on(false)
		streamplayer.disable()
	else:
		UserPrefs.set_music_on(true)
		streamplayer.enable()
		if state == STATE_PLAYING or state == STATE_PLAYING_PAUSED:
			streamplayer.start_play()

func _on_SoundButton_toggled( pressed ):
	UserPrefs.set_sound_on(!pressed)

func _on_CreditsButton_pressed():
	if state == STATE_NOT_STARTED:
		state = STATE_ANIMATING
		
		ui_animationplayer.queue("close_menu")
		animationplayer.queue("show_credits")
		
		yield( animationplayer, "finished" )
		
		_remove_debrils()
		player.call_deferred("_die")
		player = null
		
		state = STATE_DEAD
		
		#animationplayer.queue("enter_notplaying_credits")
	elif state == STATE_PLAYING_PAUSED:
		state = STATE_ANIMATING
		animationplayer.queue("show_credits")
		yield(animationplayer, "finished")
		state = STATE_PLAYING_CREDITS
	
	elif state == STATE_DEAD:
		state = STATE_ANIMATING
		animationplayer.queue("show_credits")
		yield(animationplayer, "finished")
		state = STATE_DEAD_CREDITS
	
	else: #ignore the press
		pass
	


func _on_ExitButton_pressed():
	get_tree().quit()


var _random_floats = FloatArray()
var _random_floats_index = -1
const _RAMDOM_INDEX_MASK = 1024-1

func init_random():
	_random_floats.resize(1024)
	for i in range(1024):
		_random_floats[i] = randf()
	_random_floats_index = -1

func random_float():
	_random_floats_index = (_random_floats_index + 1) & _RAMDOM_INDEX_MASK
	return _random_floats[_random_floats_index]

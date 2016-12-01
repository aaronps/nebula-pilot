
extends Sprite

const TEX_WITH = 1024
const TEX_HEIGHT = 1024

const TEX_SPEED = 10 # per second
const TEX_ACCEL = 5 # per second

var slow_mode = true
var speed = 0
var processing = false

var WIDTH = 480
var HEIGHT = 800

var bg1_rect = Rect2(0, TEX_HEIGHT - HEIGHT, WIDTH, HEIGHT)


var thread
var mutex
var semaphore
var thread_shall_run = false
var thread_shall_load_next = false
var thread_loaded_texture = null

func _ready():
	# randomize needed because this runs before main?
	randomize()
	
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread = Thread.new()
	
	start_thread()
	start_loading_background()

func _process(delta):
	if slow_mode:
		if speed == 0:
			return
		else:
			speed = max(speed - (TEX_ACCEL * delta), 0)
	elif speed < TEX_SPEED:
		speed = min(speed + (TEX_ACCEL * delta), TEX_SPEED)
	
	bg1_rect.pos.y -= speed * delta
	if bg1_rect.pos.y <= -HEIGHT:
		bg1_rect.pos.y += TEX_HEIGHT
	set_region_rect(bg1_rect)

func start_thread():
	if not thread.is_active():
		mutex.lock()
		
		thread_shall_run = true
		thread.start(self, "thread_func")
		
		mutex.unlock()

func stop_thread():
	if thread.is_active():
		mutex.lock();
		
		thread_shall_run = false;
		semaphore.post()
		
		mutex.unlock()
		thread.wait_to_finish()

func thread_func(_param):
	var map_order = [ 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8 ]
	var map_index = 9999
	
	mutex.lock()
	while thread_shall_run:
		if thread_shall_load_next:
			mutex.unlock()
			
			if map_index >= map_order.size():
				randomize_array(map_order)
				map_index = 0
			
			var tn = map_order[map_index]
			map_index += 1
			
			var tex = load(str("res://backgroundstars/", tn ,".tex"))
			
			mutex.lock()
			
			thread_loaded_texture = tex
			thread_shall_load_next = false
		
		mutex.unlock()
		semaphore.wait()
		mutex.lock()

static func randomize_array(array):
	var rnd
	var tmp
	for i in range(array.size()-1, 1, -1):
		tmp = array[i]
		rnd = randi() % i
		array[i] = array[rnd]
		array[rnd] = tmp

func start_loading_background():
	mutex.lock()
	
	if  (thread_loaded_texture == null) and (thread_shall_load_next == false):
		thread_shall_load_next = true
		semaphore.post()
	
	mutex.unlock()

func finish_loading_background():
	var tex = null
	mutex.lock()
	
	if thread_loaded_texture != null:
		tex = thread_loaded_texture
		thread_loaded_texture = null
	elif thread_shall_load_next == false: # this is for security, but I think shouldn't be here, it should start with start_loading_background
		thread_shall_load_next = true
		semaphore.post()
	
	mutex.unlock()
	
	if tex != null:
		set_texture(tex)
		
		var x_pos = randi() % (TEX_WITH - WIDTH)
		bg1_rect.pos.x = x_pos
		
		set_region_rect(bg1_rect)
		
		set_region(true)
		if not processing:
			processing = true
			set_process(true)
		
		return true
	return false

func set_viewsize(s):
	WIDTH = int(s.width)
	HEIGHT = int(s.height)
	
	bg1_rect.size = s
	set_region_rect(bg1_rect)
	

func setSlowMode(b):
	slow_mode = b


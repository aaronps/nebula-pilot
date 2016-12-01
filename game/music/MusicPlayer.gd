
extends StreamPlayer

var thread

var musics = [ 
	[ "res://music/nebula_01.ogg", 8 ],
	[ "res://music/nebula_02.ogg", 8 ],
	[ "res://music/nebula_03.ogg", 9.6 ]
]
# nebula_01 loop @ 8
# nebula_02 loop @ 8
# nebula_03 loop @ 9.6

var music_order = [ 0, 0, 1, 1, 2, 2 ]
var music_index = 9999

func _ready():
	set_paused(!UserPrefs.music_on)
	thread = Thread.new()

func enable():
	if is_paused():
		set_paused(false)
		prepare_next()

func disable():
	if !is_paused():
		stop()
		set_paused(true)

func next_song(n):
	var r = load(musics[n][0])
	set_stream(r)
	set_loop_restart_time(musics[n][1])


func prepare_next():
	if !is_paused():
		if music_index >= music_order.size():
			randomize_music_order()
		var tn = music_order[music_index]
		music_index += 1
		
		if thread.is_active():
			thread.wait_to_finish()
		
		thread.start(self, "next_song", tn)

func randomize_music_order():
	var r
	var t
	for i in range(music_order.size()-1, 1, -1):
		t = music_order[i]
		r = randi() % i
		music_order[i] = music_order[r]
		music_order[r] = t
	
	music_index = 0

# this function is here to start the playing in a separate thread as to avoid jerky start, lets see if it works
func start_play():
	if thread.is_active():
		thread.wait_to_finish()
	
	thread.start(self, "play", 0)

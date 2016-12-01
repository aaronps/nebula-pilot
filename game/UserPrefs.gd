
extends Node

const PREFS_FILE = "user://userprefs.json"

var music_on = true
var sound_on = true

func _ready():
	load_prefs()

func set_music_on(value):
	if value != music_on:
		music_on = value
		save_prefs()
		on_music_on_change()

func on_music_on_change():
	if music_on:
		AudioServer.set_stream_global_volume_scale(1.0)
	else:
		AudioServer.set_stream_global_volume_scale(0.0)

func set_sound_on(value):
	if value != sound_on:
		sound_on = value
		save_prefs()
		on_sound_on_change()

func on_sound_on_change():
	if sound_on:
		AudioServer.set_fx_global_volume_scale(1.0)
	else:
		AudioServer.set_fx_global_volume_scale(0.0)

func set_prefs(prefs):
	music_on = prefs.music_on
	on_music_on_change()
	
	sound_on = prefs.sound_on
	on_sound_on_change()

func get_prefs():
	return {
		music_on = music_on,
		sound_on = sound_on
	}

func load_prefs():
	var f = File.new()
	if f.file_exists(PREFS_FILE):
		var d = {}
		var result = f.open(PREFS_FILE, File.READ)
		if  result != 0:
			print("prefs open read error: ", result)
			return false
		
		result = d.parse_json(f.get_line())
		f.close()
		if result != 0:
			print("parse prefs error: ", result)
			return false
		
		# copy or merge the data
		set_prefs(d)
		
		return true
	
	return false

func save_prefs():
	var f = File.new()
	var result = f.open(PREFS_FILE, File.WRITE)
	if result != 0:
		print("prefs open (save) error: ", result)
		return false
	
	f.store_line(get_prefs().to_json())
	f.close()
	return true

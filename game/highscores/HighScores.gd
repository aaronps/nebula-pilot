
extends TextureFrame

const SAVE_FILE = "user://highscore.dat"

var data = {
	version = 1,
	scores=["60.000","40.000","20.000","10.000","5.000"]
}

var labels

func _ready():
	labels = [
		get_node("highscore0"),
		get_node("highscore1"),
		get_node("highscore2"),
		get_node("highscore3"),
		get_node("highscore4")
	]
	
	load_scores()
	update_board()

func load_scores():
	
	var f = File.new()
	if f.file_exists(SAVE_FILE):
		var d = {}
		var result = f.open_encrypted_with_pass(SAVE_FILE, File.READ, SAVE_FILE)
		if  result != 0:
			print("open read error: ", result)
			return false
		
		result = d.parse_json(f.get_line())
		f.close()
		if result != 0:
			print("parse scores error: ", result)
			return false
		
		# copy or merge the data
		data.scores = d.scores
		
		return true
	
	return false

func save_scores():
	var f = File.new()
	var result = f.open_encrypted_with_pass(SAVE_FILE, File.WRITE, SAVE_FILE)
	if result != 0:
		print("open (save) error: ", result)
		return false
	
	f.store_line(data.to_json())
	f.close()
	return true

func add_score(score):
	var fv = format_number(score)
	var fvlen = fv.length()
	for i in range(5):
		if fvlen > data.scores[i].length() or (fvlen == data.scores[i].length() and fv.casecmp_to(data.scores[i]) > 0):
			data.scores.insert(i, fv)
			data.scores.pop_back()
			save_scores()
			update_board()
			return i
	return -1
	

func update_board():
	labels[0].set_text(format_line("1",data.scores[0]))
	labels[1].set_text(format_line("2",data.scores[1]))
	labels[2].set_text(format_line("3",data.scores[2]))
	labels[3].set_text(format_line("4",data.scores[3]))
	labels[4].set_text(format_line("5",data.scores[4]))

func format_number(value):
	var s = floor(value)
	return str(s,".",floor((value - s) * 1000)).pad_decimals(3)

func format_line(line, formatted_value):
	return(str(line,"...............".right(formatted_value.length()),formatted_value))

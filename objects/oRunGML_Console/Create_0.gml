var _me = id;
with(oRunGML_Console) {
	if id != _me instance_destroy();
}
global.RunGML_Console = _me;

RunGMLI = new RunGML_Interpreter("Console");
RunGMLI.parent = id;

last_created = noone;

toggle_key = global.RunGML_Console_toggleKey;
backspace_key = vk_backspace;
float_precision = global.RunGML_Console_floatPrecision;

age = 0;

prompt = "> ";
outprompt = "-> "
current_line = "";
cursor = "|"
cursor_pos = 1; // String indexes start at 1
history = [];
max_history = 20;
command_history = [];
command_history_pos = -1;
command_history_max = 100;
pause_game = true;

scaledown = 1.0;
left_padding = 8/scaledown;
right_padding = 8/scaledown;
top_padding = 4/scaledown;
bottom_padding = 4/scaledown;

text_color = c_lime;
text_alpha = 1.0;
line_bg_color = c_black;
line_bg_alpha = 0.75;
history_bg_color = c_dkgrey;
history_bg_alpha = 0.75;

alphabet = [
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", 
	",", ".", "/", "<", ">", "?", " ", ":", ";", "'", "[", "]", "'", "\"", "{", "}"
];

text_x = 0;
text_y = display_get_gui_height();

toggle = function(_set=!enabled) {
	enabled = _set;
	if enabled {
		age = 0;
		if pause_game global.paused = true;
	} else {
		keyboard_lastkey = -1;
		keyboard_lastchar = "";
		clear_line();
		command_history_pos = 0;
		if pause_game global.paused = false;
	}
}

clear_line = function() {
	current_line = "";
	cursor_pos = 1;
}

clear_history = function() {
	history = [];	
}

log_line = function(_l) {
	array_push(history, _l);
	if array_length(history) > max_history {
		array_delete(history, 0, 1);
	}
}

log_string = function(_s) {
	var lines = string_split(_s, ord("\n"));
	for (var i=0; i<array_length(lines); i++) {
		log_line(lines[i]);
	}
}

trim_numeric_string = function(_s) {
	_s = string_format(_s, 1, float_precision);
	_s = string_trim_end(_s, ["0"])
	if string_char_at(_s, string_length(_s)) == "." {
		_s += "0";
	}
	return _s;
}

exec_line = function(_l) {
	var _output = RunGMLI.run(json_parse(string("[{0}]", _l)))
	if _output == undefined return;
	if typeof(_output) == "array" {
		if array_length(_output) < 1 return;
	}
	if typeof(_output) == "number" {
		_output = trim_numeric_string(_output);
	}
	
	log_line(outprompt + string(_output));
}

backspace = function() {
	if cursor_pos > 1 {
		current_line = string_delete(current_line, cursor_pos-1, 1);
		cursor_pos -= 1;
	}
}

//wrap_string = function(_s, _w=60) {
//	var _count = 0;
//	var _safe = 1;
//	var _delimiters = [" ", ","]
//	for (var i=0; i<string_length(_s), i++) {
//		if array_contains(_delimiters, _s[i]) {
//		}
//	}
//}



toggle();
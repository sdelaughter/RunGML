var _me = id;
with(oRunGML_Console) {
	if id != _me instance_destroy();
}
global.RunGML_Console = _me;

RunGMLI = new RunGML_Interpreter("Console");
RunGMLI.parent = id;
RunGMLI.throw_errors = true;

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
pause_game = global.RunGML_Console_doPause;


text_color = c_lime;
text_alpha = 1.0;
line_bg_color = c_black;
line_bg_alpha = 0.75;
history_bg_color = c_dkgrey;
history_bg_alpha = 0.75;
font = global.RunGML_Console_font;
text_scale = global.RunGML_Console_scale;

// Only allow certain characters -- we don't want things like backspace and F-keys
// TODO: expand to include accents + other scripts (blacklist specials instead?)

alphabet = [
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", 
	",", ".", "/", "<", ">", "?", " ", ":", ";", "'", "\"", 
	"[", "]", "{", "}", "|", "\\", "\t"
];

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

wrap_string = function(_s, _w=undefined) {
	if is_undefined(_w) _w = display_get_gui_width();
	var _char_w = string_width("_") * text_scale;
	var _chars_per_line = floor(_w/_char_w)-1
	var _start_len = string_length(_s);
	var _n_lines = ceil(_start_len/_chars_per_line);
	for (var i=0; i<_n_lines-1; i++) {
		_s = string_insert("\n", _s, (i+1)*_chars_per_line);
	}
	return _s;
}

exec_line = function(_l) {
	var _json;
	try {
		_json = json_parse(string("[{0}]", _l))
	} catch(_e) {
		new RunGML_Error(string("Invalid Syntax\nOriginal Error:\n{0}", _e)).warn(RunGMLI)
		return undefined;
	}
	var _output = RunGMLI.run(_json)
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
var _me = id;
with(oRunGML_Console) {
	if id != _me instance_destroy();
}
global.RunGML_Console = _me;

RunGMLI = new RunGML_Interpreter("Console");
RunGMLI.parent = id;
RunGMLI.throw_errors = true;

last_created = noone;

toggle_key = RunGML_Console_toggleKey;
meta_key = vk_control;
float_precision = global.RunGML_Console_floatPrecision;

dt = 0;
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
clear_on_toggle = false;

key_hold_delay = 0.5;
key_hold_rate = 0.1;
key_hold_cooldown = {
	"backspace": key_hold_delay,
	"delete": key_hold_delay,
	"left": key_hold_delay,
	"right": key_hold_delay,
	"up": key_hold_delay,
	"down": key_hold_delay
}

text_color = c_lime;
text_alpha = 1.0;
line_bg_color = c_black;
line_bg_alpha = 0.75;
history_bg_color = c_dkgrey;
history_bg_alpha = 0.75;
font = global.RunGML_Console_font;
text_scale = global.RunGML_Console_scale;

alphabet = noone;
// Set to only allow certain characters
// TODO: expand to include accents + other scripts (blacklist specials instead?)
//alphabet = [
//	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
//	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
//	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
//	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
//	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
//	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", 
//	",", ".", "/", "<", ">", "?", " ", ":", ";", "'", "\"", 
//	"[", "]", "{", "}", "|", "\\", "\t"
//];

separators = [" ", ",", ".", ":", ";", "'", "\"", "_", "-", "<", ">", "[", "]", "{", "}"]

toggle = function(_set=!enabled) {
	if !RunGML_Console_canToggle {
		enabled = false;
		return;
	}
	enabled = _set;
	if enabled {
		age = 0;
		keyboard_lastkey = -1;
		keyboard_lastchar = "";
		keyboard_string = ""
		if clear_on_toggle {
			clear_line();
			command_history_pos = 0;
		}
	}
	RunGML_Console_OnToggle(enabled);
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
	var _n_lines = array_length(lines);
	for (var i=0; i<_n_lines; i++) {
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
		_json = RunGML_Read(string("[{0}]", _l))
	} catch(_e) {
		new RunGML_Error(string("Invalid Syntax\nOriginal Error:\n{0}", _e)).warn(RunGMLI)
		return undefined;
	}
	var _output = RunGMLI.run(_json)
	if _output == undefined return;
	if is_array(_output) {
		if array_length(_output) < 1 return;
	}
	if is_numeric(_output) {
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

delete_char = function(){
	current_line = string_delete(current_line, cursor_pos, 1);
	cursor_pos = max(1, min(string_length(current_line) + 1, cursor_pos));
}

cursor_left = function(_amt=1) {
	cursor_pos = max(1, cursor_pos - _amt);
}
		
cursor_right = function(_amt=1) {
	cursor_pos = min(string_length(current_line) + 1, cursor_pos + _amt);
}

history_prev = function() {
	if array_length(command_history) < 1 return false;
	command_history_pos--;
	if command_history_pos < 0 {
		command_history_pos = array_length(command_history) - 1;
	}
	current_line = command_history[command_history_pos];
	cursor_pos = string_length(current_line) + 1;
	return true;
}

history_next = function() {
	if array_length(command_history) < 1 return false;
	command_history_pos++;
	if command_history_pos >= array_length(command_history) {
		command_history_pos = -1;
		current_line = "";
		cursor_pos = 1;
	}
	try {
		current_line = command_history[command_history_pos];
	} catch(_e) {
		current_line = "";	
	}
	cursor_pos = string_length(current_line) + 1;
}

enter = function() {
	log_line(prompt + string(current_line));
	var n_command_history = array_length(command_history)
	if n_command_history > 0 {
		if current_line != command_history[n_command_history-1] {
			array_push(command_history, current_line);
			if array_length(command_history) > command_history_max {
				array_delete(command_history, 0, 1);
			}
		}
	} else {
		array_push(command_history, current_line);
	}
	try {
		exec_line(current_line);
	} catch(_e) {
		log_string(_e);	
	}
	clear_line();
	command_history_pos = -1;
}	


key_hold_check_and_update = function(_keybind, _name, _f, _args=[]) {
	if keyboard_check(_keybind) {
		if keyboard_check_pressed(_keybind) {
			method_call(_f, _args)
			struct_set(key_hold_cooldown, _name, key_hold_delay);
			return true;
		} else {
			var _old = struct_get(key_hold_cooldown, _name)
			var _new = _old - dt;
			
			if _new <= 0 {
				method_call(_f, _args);
				struct_set(key_hold_cooldown, _name, key_hold_rate);	
				return true;
			} else struct_set(key_hold_cooldown, _name, _new);
		}
	} else {
		 struct_set(key_hold_cooldown, _name, key_hold_delay);
	}
	return false;
}
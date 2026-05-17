if !enabled exit;
//if !keyboard_check(vk_anykey) exit;

if keyboard_check(meta_key) {
	if keyboard_check_pressed(ord("L")) {
		clear_history();	
	}
	if keyboard_check_pressed(ord("C")) or keyboard_check_pressed(vk_backspace) {
		clear_line();
	}
	if keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left) {
		cursor_pos = 1;
	}
	if keyboard_check_pressed(ord("E")) or keyboard_check_pressed(vk_right) {
		cursor_pos = string_length(current_line) + 1;
	}
} else {

	key_hold_check_and_update(vk_backspace, "backspace", backspace);
	key_hold_check_and_update(vk_delete, "delete", delete_char);
	key_hold_check_and_update(vk_left, "left", cursor_left);
	key_hold_check_and_update(vk_right, "right", cursor_right);
	key_hold_check_and_update(vk_up, "up", history_prev);
	key_hold_check_and_update(vk_down, "down", history_next);

	if keyboard_check_pressed(vk_enter) {
		enter();
	} else{
		if is_undefined(alphabet) {
			current_line = string_insert(keyboard_string, current_line, cursor_pos);
			cursor_pos += string_length(keyboard_string);
		} else {
			if array_contains(alphabet, keyboard_lastchar) {
				current_line = string_insert(keyboard_lastchar, current_line, cursor_pos);
				cursor_pos += 1;
			}
		}
	}
}

keyboard_string = ""
keyboard_lastkey = -1;
keyboard_lastchar = "";
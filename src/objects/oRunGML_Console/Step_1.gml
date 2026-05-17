dt = delta_time/1000000.0;
if enabled age += dt;

if keyboard_check_pressed(toggle_key) {
	toggle();
}

//if keyboard_check_pressed(vk_f5) {
//	show_debug_overlay(not is_debug_overlay_open())	
//}
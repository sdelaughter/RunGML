if global.RunGML_Console_superPersistent {
	var _other_exists = false;
	var _me = id;
	with(oRunGML_Console) {
		if id != _me _other_exists = true;
	}
	if !_other_exists instance_create_depth(0, 0, 0, oRunGML_Console);
}
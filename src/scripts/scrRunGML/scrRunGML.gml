#macro RunGML_Version "1.5.0"
#macro RunGML_Homepage "https://github.com/sdelaughter/RunGML"

global.RunGML_Ops = {};
global.RunGML_Aliases = {};
global.RunGML_DidInit = false;

function RunGML_Interpreter(_name="RunGML_I") constructor {
	if !global.RunGML_DidInit RunGML_Init();
	
	name = _name;
	ops = global.RunGML_Ops;
	aliases = global.RunGML_Aliases;
	debug = global.RunGML_I_debug;
	throw_errors = global.RunGML_throwErrors;
	registers = {};
	recursion = -1;
	loop_depth = -1;
	loop_iter = [];
	
	run = function(_l) {
		static _temp_list_cache = [];
		
		var _list_length = array_length(_l);
		if _list_length < 1 return;
		
		//Pop a temporary array out of our cache. If no array is available, create a new one
		var _temp_list = array_pop(_temp_list_cache) ?? [];
		
		//Copy the contents of our input list to the temporary list
		array_copy(_temp_list, 0, _l, 0, _list_length);
		
		recursion += 1
		if debug show_debug_message(@"RunGML_I:{0}[{1}].run({2})", name, recursion, _temp_list);
		for (var i=0; i<_list_length; i++) {
			if is_array(_temp_list[i]) {
				_temp_list[i] = run(_temp_list[i]);
			}
		}
		
		var _op_name = array_shift(_temp_list);
		while struct_exists(aliases, _op_name) {
			// While to allow for nested aliases
			_op_name = struct_get(aliases, _op_name);
		}
		var _out = _op_name;
		
		if struct_exists(ops, _op_name) {
			var _op = struct_get(ops, _op_name);
			if debug show_debug_message(@"RunGML_I:{0}[{1}].exec({2}({3}))", name, recursion, _op_name, _temp_list);
			_out = _op.exec(self, _temp_list);
			if is_instanceof(_out, RunGML_Error) {
				_out.warn(self);
			}
		} else if global.RunGML_useBuiltinOps and _op_name != -1 {
			var _asset = asset_get_index(_op_name);
			if _asset != -1 {
				if is_callable(_asset) {
					_out = script_execute_ext(_asset, _temp_list);
				} else _out = _asset;
			}
		}
		
		recursion -= 1;
		
		//Return the temporary list to the global stack
		array_resize(_temp_list, 0);
		array_push(_temp_list_cache, _temp_list);
		
		return _out;
	}
}

function RunGML_Read(_string) {
	if global.RunGML_importLooseJSON {
		return LooseJSONRead(_string);
	} else {
		return json_parse(_string);
	}
}

function RunGML_Write(_data, _pretty=false) {
	if global.RunGML_exportLooseJSON {
		return LooseJSONWrite(_data, _pretty);
	} else {
		return json_stringify(_data, _pretty);
	}
}

function RunGML_Error(_msg="") constructor {
	prefix = string("### {0}_START ###\n", instanceof(self));
	suffix = string("\n### {0}_END ###", instanceof(self));
	msg = string(_msg);
	static warn = function(_i=undefined) {
		var _formatted = prefix + msg + suffix
		if not is_undefined(_i) {
			if _i.throw_errors throw(_formatted);
			return;
		}
		show_debug_message(_formatted);
	}
}

function RunGML_Constraint(_check=undefined, _doc=undefined) constructor {
	if is_undefined(_check) {
		_check = function(_l) {return true}
	}
	check = _check;

	if is_undefined(_doc) {
		doc = function() {return string("true")}
	}
	doc = _doc;
}

function RunGML_Constraint_ArgCount(_op="eq", _count=undefined) : RunGML_Constraint() constructor {
	count = _count
	op = _op
	err_msg = @"ArgCount constraint violated
    - args: {0}
    - test: {1}
    - got: {2}"
	doc = function() {return string("count(args) {0} {1}", op, count)}
	check = function(_l) {
		var _valid;
		var _len = array_length(_l);
		switch(op) {
			case "eq":
				_valid = _len == count;
				break;
			case "nq":
				_valid = _len != count;
				break;
			case "gt":
				_valid = _len > count;
				break;
			case "geq":
				_valid = _len >= count;
				break;
			case "lt":
				_valid = _len < count;
				break;
			case "leq":
				_valid = _len <= count;
				break;
			case "in":
				_valid = array_contains(count, _len);
				break;
		}
		if !_valid return new RunGML_Error(string(err_msg, _l, doc(), _len))
		return _valid;
	}
}

function RunGML_Constraint_ArgType(_index="all", _types=undefined, _required=true, _strict_bool=false): RunGML_Constraint() constructor {
	index = _index;
	types = _types;
	required = _required
	strict_bool = _strict_bool;
	if types == "numeric" types = ["number", "int32", "int64"];
	if types == "alphanumeric" types = ["string", "number", "int32", "int64"];
	if !is_array(types) {
		types = [types];
	}
	doc = function() {
		var _docstring = string("typeof(args[{0}]) in {1}", index, types)
		if required _docstring += " (required)"
		else _docstring += " (optional)"
		return _docstring
	}
	err_msg = @"ArgType constraint violated
    - args: {0}
    - test: {1}
    - got: {2}"
	
	check = function(_l) {
		if is_undefined(types) return true;
		var _val, _type;
		if index == "all" {
			var _n_args = array_length(_l);
			for (var i=0; i<_n_args; i++) {
				_val = _l[i];
				_type = typeof(_val);
				if not array_contains(types, _type) {
					return new RunGML_Error(string(err_msg, _l, doc(), _type))
				}
			}
		} else {
			if index >= array_length(_l) {
				if required {
					_type = undefined;
				} else return true;
			} else {
				_val = _l[index];
				_type = typeof(_val)
			}
			
			if not array_contains(types, _type){
				if !strict_bool and array_contains(types, "bool") {
					try {
						var _booled = bool(_val);
						if is_bool(_booled) {
							_l[index] = _booled;
							return true;
						}
					} catch(_e){}
				}
				return new RunGML_Error(string(err_msg, _l, doc(), _type));
			}
		}
		return true;
	}
}

function RunGML_Op(_name, _f, _desc="", _constraints=[], _i=undefined, _overwrite=false) constructor {
	var _aliases, _ops;
	if is_undefined(_i) {
		_aliases = global.RunGML_Aliases;
		_ops = global.RunGML_Ops;
	} else {
		_aliases = _i.aliases;
		_ops = _i.ops;
	}
	
	var _err = [];
	if struct_exists(_ops, _name) and not (_overwrite or global.RunGML_overwriteOps) {
		_err = new RunGML_Error(string("Cannot redefine existing operator: {0}", _name));
	}
	if struct_exists(_aliases, _name) {
		if (_overwrite or global.RunGML_overwriteAliases) {
			// Figure out which operator the alias was pointing to before
			var _did_resolve_to = RunGML_aliasResolvesTo(_name, _i);
		
			// Search recursively backwards for any other aliases that point to this alias
			var _pointed_to_by = RunGML_listAliasesOf(_name, _i);
			array_push(_pointed_to_by, _name)
		
			// Remove higher order aliases from old op
			var _n_pointers = array_length(_pointed_to_by);
			var _pointer, _index, _old_op, _new_op;
			for (var i=0; i<_n_pointers; i++) {
				_pointer = _pointed_to_by[i];
				_old_op = struct_get(_ops, _did_resolve_to)
			
				if !is_undefined(_old_op) {
					_index = array_get_index(struct_get(_old_op, "aliases"), _pointer);
					array_delete(struct_get(_old_op, "aliases"), _index, 1);
				}
			}
			struct_remove(_aliases, _name);
		} else {
			_err = new RunGML_Error(string("Cannot define operator with existing alias name: {0} -> {1}", _name, struct_get(_aliases, _name)));
		}
	}
	
	if is_instanceof(_err, RunGML_Error) {
		_err.warn(_i);
		return _err;
	}

	name = _name;
	aliases = [];
	f = _f;
	desc = _desc;
	constraints = _constraints;
	static help = function() {
		var _docstring = string(@"### {0}", name);
		_docstring += string("\n{0}", desc);
		if is_constant() {
			_docstring += $" [constant] = {RunGML_float_format(f)}"
		}
		if array_length(aliases) > 0 {
			_docstring += $"\n- aliases: {aliases}";
		}
		var _n_constraints = array_length(constraints);
		if _n_constraints > 0 {
			_docstring += "\n- constraints:";
			for (var i=0; i<_n_constraints; i++) {
				_docstring += $"\n    - {constraints[i].doc()}";
			}
		}
		return _docstring;
	}
	
	static exec = function(_i, _l) {
		var _out = undefined;
		var _err;
		if global.RunGML_I_checkConstraints {
			_err = valid(_i, _l);
		} else {
			_err = true;	
		}
		if is_instanceof(_err, RunGML_Error) return _err;
		else {
			if is_method(f) {
				try {
					_out = script_execute(f, _i, _l);
				} catch(_e) {
					_out = new RunGML_Error(string("Operator '{0}' failed to execute list: {1}\nOriginal error:\n{2}", name, _l, _e));
				}
			}
			else _out = f;
		}
		return _out;
	}
	
	static valid = function(_i, _l) {
		var _constraint, _err;
		var _n_constraints = array_length(constraints);
		for(var i=0; i<_n_constraints; i++) {
			_constraint = constraints[i];
			_err = constraints[i].check(_l)
			if is_instanceof(_err, RunGML_Error) {
				_err.msg += string("\n    - operator: {0}", name);
				_err.warn(_i);
				return false;
			}
		}
		return true;
	}
	
	static is_constant = function() {
		return !is_method(f)
	}

	struct_set(global.RunGML_Ops, name, self);
}

function RunGML_aliasResolvesTo(_nickname, _i=undefined) {
	var _aliases, _ops;
	var _exists = false;
	if is_undefined(_i) {
		_aliases = global.RunGML_Aliases;
		_ops = global.RunGML_Ops;
	} else {
		_aliases = _i.aliases;
		_ops = _i.ops;
	}
	
	var _resolves_to = _nickname;
	while struct_exists(_aliases, _resolves_to) {
		_resolves_to = struct_get(_aliases, _resolves_to);
	}
	return _resolves_to;
}

function RunGML_listAliasesOf(_search_for, _i=undefined) {
	var _aliases, _ops;
	if is_undefined(_i) {
		_aliases = global.RunGML_Aliases;
		_ops = global.RunGML_Ops;
	} else {
		_aliases = _i.aliases;
		_ops = _i.ops;
	}
	
	var _pointed_to_by = [];
	var _to_check = [];
	
	var _alias_nicknames = struct_get_names(_aliases);
	var _n_aliases = array_length(_alias_nicknames);
	for (var i=0; i<_n_aliases; i++) {
		var _nickname = _alias_nicknames[i];
		var _name = struct_get(_aliases, _nickname);
		if _name == _search_for {
			array_push(_pointed_to_by, _nickname);
			array_push(_to_check, _nickname);
		}
	}
	
	var _did_check = [];
	var _tmp_nickname, _tmp_name, _checking;
	while array_length(_to_check) > 0 {
		_checking = array_shift(_to_check);
		array_push(_did_check, _checking);
		for (var i=0; i<_n_aliases; i++) {
			_tmp_nickname = _alias_nicknames[i];
			_tmp_name = struct_get(_aliases, _tmp_nickname);
			if _tmp_name == _checking {
				if not array_contains(_pointed_to_by, _tmp_nickname) {
					array_push(_pointed_to_by, _tmp_nickname);
				}
				if not array_contains(_did_check, _tmp_nickname) {
					array_push(_to_check, _tmp_nickname);	
				}
			}
		}
	}
	return _pointed_to_by;
}

function RunGML_alias(_nickname, _name, _i=undefined, _overwrite=false) {
// Create an alias for an operator
	var _aliases, _ops;
	var _exists = false;
	if is_undefined(_i) {
		_aliases = global.RunGML_Aliases;
		_ops = global.RunGML_Ops;
	} else {
		show_debug_message($"_i: {_i}");
		_aliases = _i.aliases;
		_ops = _i.ops;
	}
	var _err = [];
	
	if struct_exists(_aliases, _nickname) {
		_exists = true;
		if not (_overwrite or global.RunGML_overwriteAliases) {
			_err = new RunGML_Error(string("Cannot redefine alias: {0} -> {1}", _nickname, struct_get(_aliases, _nickname)));
			_err.warn(_i);
			return _err;
		}
	}
	
	if struct_exists(_ops, _nickname) {
		if (_overwrite or global.RunGML_overwriteOps) {
			struct_remove(_ops, _nickname);
		} else {
			_err = new RunGML_Error(string("Cannot create alias with defined operator as nickname: {0}", _nickname));
			_err.warn(_i);
			return _err;
		}
	}
	
	// Figure out what the alias will point to now
	var _resolves_to = RunGML_aliasResolvesTo(_name, _i)

	if _exists {
		// Figure out which operator the alias was pointing to before
		var _did_resolve_to = RunGML_aliasResolvesTo(_nickname, _i);
		
		// Search recursively backwards for any other aliases that point to this alias
		var _pointed_to_by = RunGML_listAliasesOf(_nickname, _i)
		array_push(_pointed_to_by, _nickname);
		
		// Remove higher order aliases from old op and add to new
		var _n_pointers = array_length(_pointed_to_by);
		var _pointer, _index, _old_op, _new_op;
		for (var i=0; i<_n_pointers; i++) {
			_pointer = _pointed_to_by[i];
			_old_op = struct_get(_ops, _did_resolve_to)
			_new_op = struct_get(_ops, _resolves_to)
			
			if !is_undefined(_old_op) {
				_index = array_get_index(struct_get(_old_op, "aliases"), _pointer);
				array_delete(struct_get(_old_op, "aliases"), _index, 1);
			}
			if !is_undefined(_new_op) {
				array_push(struct_get(_new_op, "aliases"), _pointer);
			}
		}
	}
	
	if not _exists and struct_exists(_ops, _resolves_to) {
		array_push(struct_get(struct_get(_ops, _resolves_to), "aliases"), _nickname);
	}
	struct_set(_aliases, _nickname, _name);
	return [];
}

function RunGML_Enum(_name, _f=undefined, _desc="", _constraints=undefined, _i=undefined, _overwrite=false) : RunGML_Op(_name, _f, _desc, _constraints, _i, _overwrite) constructor {
	if is_undefined(_f) _f = {}
	members = _f;
	member_names = variable_struct_get_names(members);
	array_sort(member_names, function(a, b) {
	    return struct_get(members, a) - struct_get(members, b);
	});
	
	f = function(_i, _l) {
		if array_length(_l) < 1 {
			return member_names;	
		} else if struct_exists(members, _l[0]) {
			return struct_get(members, _l[0]);	
		} else {
			return new RunGML_Error($"Invalid enum member: {name}.{_l[0]}\nValid members are: {member_names}");
		}
	}
	if is_undefined(_constraints) {
		constraints = [new RunGML_Constraint_ArgType(0, ["string"], false)]
	}
	if string_length(_desc) < 1 {
		desc = $"Accessor for the {_name} enum.\n- members: {member_names}"
	}
}

function RunGML_float_format(_val, _digits=undefined) {
	if string_count(".", string(_val)) != 1 return _val;
	try {
		_val = real(_val);
		if is_undefined(_digits) _digits = global.RunGML_floatPrecision;
		var _total = string_length(string(floor(_val)));
		var _out = string_format(_val, _total, _digits);
		if not global.RunGML_floatTrailingZeroes {
			while string_char_at(_out, string_length(_out)) == "0" {
				_out = string_trim_end(_out, "0")
			}
		}
		return _out;
	} catch(_e) {
		return _val;	
	}
}

function RunGML_clone(_l) {
// Deep copy a nested list.  Enables program reuse
	return variable_clone(_l);
}

function RunGML_color(_name, _color) {
// Add a new color definition
	struct_set(global.RunGML_Colors	, _name, _color)
}

function RunGML_Load_GM_Manual_Index(_path="RunGML/gm_manual.json") {
	// JSON obtained from https://manual.gamemaker.io/monthly/en/helpdocs_keywords.json
	// Last updated 2026-05-20
	if !file_exists(_path) return {};
	var _file = file_text_open_read(_path);
	var _json_string = "";
	while (!file_text_eof(_file)) {
		_json_string += file_text_read_string(_file);
		file_text_readln(_file);
	}
	file_text_close(_file);
	return RunGML_Read(_json_string);	
}

function RunGML_Munge(_json, _gmli=undefined, _prefix=undefined) {
	if is_undefined(_gmli) {
		_gmli = new RunGML_Interpreter();
	}
	
	if is_undefined(_prefix) {
		_prefix = global.RunGML_mungePrefix;
	}
	
	if is_array(_json) {
		if array_length(_json) < 1 return _json;
		if _json[0] == _prefix {
			var _ = array_shift(_json);
			return _gmli.run(_json);
		} else {
			var _n = array_length(_json);
			var _val;
			for (var i=0; i<_n; i++) {
				_val = _json[i];
				if is_array(_val) or is_struct(_val) {
					_json[i] = RunGML_Munge(_val, _gmli, _prefix);	
				}
			}
		}
		return _json;
	} else if is_struct(_json) {
		var _keys = struct_get_names(_json);
		var _n_keys = array_length(_keys);
		var _key, _val;
		for (var i=0; i<_n_keys; i++) {
			_key = _keys[i];
			_val = struct_get(_json, _key);
			
			var _did_change = false;
			if string_starts_with(_key, _prefix) {
				var _prog = string_trim_start(_key, [_prefix]);
				struct_remove(_json, _key);
				_key = _gmli.run(RunGML_Read(_prog));
				_did_change = true;	
			}
			
			if is_array(_val) or is_struct(_val) {
				_val = RunGML_Munge(_val, _gmli, _prefix);
				_did_change = true;
			}
			
			if _did_change struct_set(_json, _key, _val);
		}
	}
	return _json;
}

function RunGML_Init() {
	global.RunGML_Ops = {};
	global.RunGML_Aliases = {};

	RunGML_DefineOps();
	RunGML_DefineAliases();
	RunGML_DefineCustom();
	
	global.RunGML_GM_Manual_Index = RunGML_Load_GM_Manual_Index();
	global.RunGML_DidInit = true;
}
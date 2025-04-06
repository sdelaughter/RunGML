#macro RunGML_Version "2025_04_05_00"
#macro RunGML_Homepage "https://github.com/sdelaughter/RunGML"

function RunGML_Interpreter(_name="RunGML_I") constructor {
	name = _name;
	ops = global.RunGML_Ops;
	aliases = global.RunGML_Aliases;
	debug = global.RunGML_I_debug;
	throw_errors = global.RunGML_throwErrors;
	registers = {};
	recursion = 0;
	
	run = function(_l) {
		if array_length(_l) < 1 return;
		recursion += 1
		if debug show_debug_message(@"RunGML_I:{0}[{1}].run({2})", name, recursion, _l);
		for (var i=0; i<array_length(_l); i++) {
			if typeof(_l[i]) == "array" {
				_l[i] = run(_l[i]);
			}
		}
		
		var _op_name = array_shift(_l);
		var _out = _op_name;
		while struct_exists(aliases, _op_name) {
			_op_name = struct_get(aliases, _op_name);	
		}
		if struct_exists(ops, _op_name) {
			var _op = struct_get(ops, _op_name);
			if debug show_debug_message(@"RunGML_I:{0}[{1}].exec({2}({3}))", name, recursion, _op_name, _l);
			_out = _op.exec(self, _l);
			if is_instanceof(_out, RunGML_Error) {
				_out.warn(self);
				//_out = undefined;
			}
		}
		recursion -= 1;
		return _out;
	}
}

function RunGML_Error(_msg="") constructor {
	prefix = string("### {0}_START ###\n", instanceof(self));
	suffix = string("\n### {0}_END ###", instanceof(self));
	msg = string(_msg);
	warn = function(_i=noone) {
		var _formatted = prefix + msg + suffix
		if _i != noone {
			if _i.throw_errors throw(_formatted);
			return;
		}
		show_debug_message(_formatted);
	}
}

function RunGML_Constraint(_check=noone, _doc=noone) constructor {
	if _check == noone {
		_check = function(_l) {return true}
	}
	check = _check;

	if _doc == noone {
		doc = function() {return string("true")}
	}
	doc = _doc;
}

function RunGML_Constraint_ArgCount(_op="eq", _count=noone) : RunGML_Constraint() constructor {
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

function RunGML_Constraint_ArgType(_index="all", _types=noone, _required=true): RunGML_Constraint() constructor {
	index = _index;
	types = _types;
	required = _required
	if types == "numeric" types = ["number", "int32", "int64"];
	if types == "alphanumeric" types = ["string", "number", "int32", "int64"];
	if typeof(types) != "array" types = [types];
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
		if types == noone return true;
		var _val, _type;
		if index == "all" {
			for (var i=0; i<array_length(_l); i++) {
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
				return new RunGML_Error(string(err_msg, _l, doc(), _type));
			}
		}
		return true;
	}
}

function RunGML_Op(_name, _f, _desc="", _constraints=[]) constructor {
	if struct_exists(global.RunGML_Ops, _name) and not global.RunGML_overwriteOps return;

	name = _name;
	aliases = [];
	f = _f;
	desc = _desc;
	constraints = _constraints;
	help = function() {
		var _docstring = string(@"- {0}", name);
		if array_length(aliases) > 0 _docstring += string("\n    - aliases: {0}", aliases)
		_docstring += string("\n    - desc: {0}", desc);
		if typeof(f) != "method" _docstring += " (constant)"
		var _n_constraints = array_length(constraints);
		if _n_constraints > 0 {
			_docstring += "\n    - constraints:";
			for (var i=0; i<_n_constraints; i++) {
				_docstring += string("\n        - {0}", constraints[i].doc())
			}
		}
		return _docstring;
	}
	
	exec = function(_i, _l) {
		var _out = undefined;
		var _err = valid(_i, _l);
		if is_instanceof(_err, RunGML_Error) return _err;
		else {
			if typeof(f) == "method" {
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
	
	valid = function(_i, _l) {
		var _constraint, _err;
		for(var i=0; i<array_length(constraints); i++) {
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

	struct_set(global.RunGML_Ops, name, self);
}

function RunGML_alias(_nickname, _name, _i = noone) {
// Create an alias for an operator
	var _aliases, _ops;
	if _i == noone {
		_aliases = global.RunGML_Aliases;
		_ops = global.RunGML_Ops;
	} else {
		_aliases = _i.aliases;
		_ops = _i.ops;
	}
	var _out = [];
	if struct_exists(_aliases, _nickname) {
		_out = new RunGML_Error(string("Cannot redefine alias: {0} -> {1}", _nickname, struct_get(_aliases, _nickname)));
	}
	if struct_exists(_ops, _nickname) {
		_out = new RunGML_Error(string("Cannot create alias with defined operator as nickname: {0}", _nickname, struct_get(_aliases, _nickname)));
	}
	if not struct_exists(_ops, _name) {
		_out = new RunGML_Error(string("Cannot create alias for non-existent operator: {0}", _name));
	}
	if is_instanceof(_out, RunGML_Error) {
		if _i == noone _out.warn();
		return _out;
	}
	
	struct_set(_aliases, _nickname, _name);
	array_push(struct_get(struct_get(_ops, _name), "aliases"), _nickname);
	return [];;
}

function RunGML_clone(_l) {
// Deep copy a nested list.  Enables program reuse
	return json_parse(json_stringify(_l));	
}


function RunGML_color(_name, _color) {
// Add a new color definition
	struct_set(global.RunGML_Colors	, _name, _color)
}


/* Operator Definitions
Additional operators should be defined in scrRunGML_Config
Make a backup of that file before updating RunGML
Then you can restore your custom settings and operators after updating
*/

global.RunGML_Ops = {}
global.RunGML_Aliases = {}

#region Constants

new RunGML_Op("version", RunGML_Version,
@"Returns the RunGML version number
    - args: []
    - output: string",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("gm_version", GM_version,
@"Returns the game's version number,
    - args: []
    - output: string",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("true", true,
@"Return the GameMaker constant true
    - args: []
    - output: true",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("false", false,
@"Return the GameMaker constant false
    - args: []
    - output: false",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("noone", noone,
@"Return the GameMaker constant noone
    - args: []
    - output: noone",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op ("undefined", undefined,
@"Return the GameMaker constant undefined
    - args: []
    - output: undefined",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op ("pi", pi,
@"Return the value of the mathematical constant e
    - args: []
    - output: pi",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("e", exp(1),
@"Return the value of the mathematical constant e
    - args: []
    - output: e",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("phi", (1+sqrt(5))/2.0,
@"Return the value of the mathematical constant phi
    - args: []
    - output: phi",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

#endregion Constants

#region Metadata

new RunGML_Op("update",
	function(_i, _l=[]) {
		url_open(RunGML_Homepage);
		return [];
	},
@"Returns the RunGML web address
    - args: []
    - output: string",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("op_count",
	function(_i, _l=[]) {
		return struct_names_count(_i.ops);
	},
@"Returns the number of supported operators
    - args: []
    - output: number",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("op_list",
	function(_i, _l=[]) {
		var _op_list = struct_get_names(_i.ops);
		array_sort(_op_list, true);
		return _op_list;
	},
@"Returns a list of supported operators
    - args: []
    - output: [string, *]",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("op_names",
	function(_i, _l=[]) {
		var _op_list = struct_get_names(_i.ops);
		array_sort(_op_list, true);
		var _str = "";
		for (var i=0; i<array_length(_op_list); i++) {
			if i > 0 _str += ", ";
			_str += _op_list[i];
		}
		return _str;
	},
@"Returns a string listing names of supported operators
    - args: []
    - output: string",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("help",
	function(_i, _l=[]) {
		if array_length(_l) > 0 {
			var _op_name = _l[0];
			if struct_exists(_i.aliases, _op_name) {
				_op_name = struct_get(_i.aliases, _op_name);
			}
			var _op = struct_get(_i.ops, _op_name)
			if !is_instanceof(_op, RunGML_Op){
				return string("{0} is not a valid RunGML operator. Try \"help\".", _l[0])
			}
			return _op.help();
		} else {
			return _i.run(
				["string", @'
# RunGML

Version: {0}

Homepage: {1}

Run ["update"] to visit the homepage to read documentation, check for updates, report bugs, or request features.

Run ["op_names"] to list all {2} supported operators.

Run ["help", "some_operator_name"] to get documentation on a specific operator.

Run ["manual"] to generate full documentation for all operators.
', 
					["version"],
					RunGML_Homepage,
					["op_count"],
				]
			)
		}	
	},
@"Display documentation for RunGML, or for an operator named by the first argument.
    - args: [(string)]
    - output: string", 
	[
		new RunGML_Constraint_ArgCount("leq", 1),
		new RunGML_Constraint_ArgType(0, "string", false)
	]
)
	
new RunGML_Op ("manual",
	function(_i, _l) {
		var _filename = "RunGML/manual.md";
		if array_length(_l) > 0 _filename = _l[0];
		if file_exists(_filename) file_delete(_filename);
		var _f = file_text_open_append(_filename)
		var _ops = variable_struct_get_names(_i.ops);
		array_sort(_ops, true);
		var _op, _op_name;
		file_text_write_string(_f, _i.run(["help"]));
		file_text_write_string(_f, "\n\n## Operators\n");
		for (var i=0; i<array_length(_ops); i++) {
			_op_name = _ops[i];
			_op = struct_get(_i.ops, _op_name)
			if _op.name != _op_name continue; // Don't re-document aliases
			file_text_write_string(_f, "\n"+_op.help()+"\n")
		}
		file_text_close(_f);
		url_open(_filename)
		return [];
	},
@"Write full documentation for all RunGML operators to a file and view it in the browser.
    - args: [(filename)]
    - output: []",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
	
new RunGML_Op ("this",
	function(_i, _l) {
		return _i;
	},
@"Return a reference to the current RunGML interpreter
    - args: []
    - output: instance",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)
	
new RunGML_Op("parent",
	function(_i, _l) {
		switch(array_length(_l)) {
			case 0:
				return _i.parent;
				break;
			case 1:
				return struct_get(_i.parent, _l[0]);
				break;
			case 2:
			default:
				struct_set(_i.parent, _l[0], _l[1]);
				break;
		}
		
	},
@"Return a reference to the RunGML interpreter's parent object.
    - args: []
    - output: instance",
	[new RunGML_Constraint_ArgCount("leq", 2)]
)
	
new RunGML_Op("console",
	function(_i, _l) {
		if !instance_exists(oRunGML_Console) {
			global.RunGML_Console = instance_create_depth(0, 0, 0, oRunGML_Console);
		}
		switch(array_length(_l)) {
			case 0:
				return global.RunGML_Console;
				break;
			case 1:
				return variable_instance_get(global.RunGML_Console, _l[0])
				break;
			case 2:
				variable_instance_set(global.RunGML_Console, _l[0], _l[1])
				return [];
				break;
		}
	},
@"Return a reference to the RunGML console, creating one if it doesn't exist
    - args: []
    - output: instance",
	[
		new RunGML_Constraint_ArgCount("leq", 2),
		new RunGML_Constraint_ArgType(0, "string", false)
	]
)
	
new RunGML_Op("clear",
	function(_i, _l) {
		if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
			_i.parent.clear_history();
		}
		return [];
	},
@"If run from a console, clear that console's history
    - args: []
    - output: instance",
	[new RunGML_Constraint_ArgCount("eq", 0)]
)

new RunGML_Op ("alias",
	function(_i, _l=[]) {
		switch(array_length(_l)) {
			case 0:
				return _i.aliases;
				break;
			case 1:
				var _out = [];
				if struct_exists(_i.aliases, _l[0]) {
					var _name =  struct_get(_i.aliases, _l[0]);
					_out = array_concat([_name], struct_get(struct_get(_i.ops, _name), "aliases"));
				} else if struct_exists(_i.ops, _l[0]) {
					_out = array_concat([_l[0]], struct_get(struct_get(_i.ops, _l[0]), "aliases"));
				}
				return _out;
				break;
			case 2:
			default:
				return RunGML_alias(_l[0], _l[1], _i);
				break;
		}		
	},
@"Create an operator alias. Behavior depends on the number of arguments:
        - 0: Return the interpreter's entire alias struct
        - 1: If the argument names an operator or alias, return a list of all synonyms starting with the real name.
        - 2: Creates a new alias with nickname arg0 for operator arg1.  arg0 cannot be in use, arg1 must be defined.
    - args: [(nickname), (name)]
    - output: struct or list",
	[
		new RunGML_Constraint_ArgCount("leq", 2),
		new RunGML_Constraint_ArgType(0, "string", false),
		new RunGML_Constraint_ArgType(1, "string", false)
	]
)

#endregion Metadata
	
#region Control Flow

new RunGML_Op ("pass",
	function(_i, _l=[]) {
		return [];
	},
@"Do nothing
    - args: [*]
    - output: []"
)
	
new RunGML_Op ("run",
	function(_i, _l) {
		return _i.run(_l);
	},
@"Run arguments as a program.
    - args: [*]
    - output: *"
)
	
new RunGML_Op ("exec",
	function(_i, _l) {
		return _i.run(json_parse(_l[0]));
	},
@"Execute a string as a program.
    - args: [string]
    - output: *",
	[
		new RunGML_Constraint_ArgCount("eq", 1),
		new RunGML_Constraint_ArgType(0, "string")
	]
)
	
new RunGML_Op ("last",
	function(_i, _l) {
		var _n = array_length(_l);
		if _n > 0 return _l[_n - 1];
		return [];
	},
@"Return the value of the last argument
    - args: [*]
    - output: *"
)
	
new RunGML_Op ("out",
	function(_i, _l) {
		return {"out": _l};
	},
@"Wrap argument list in a struct so it can be returned unevaluated.
    - args: [*]
    - output: struct"
)
	
new RunGML_Op ("in",
	function(_i, _l) {
		return struct_get(_l[0], "out");
	},
@"Retrieve the output list from a struct produced by the 'out' operator.
    - args: [struct]
    - output: list",
	[new RunGML_Constraint_ArgType(0, "struct")]
)
	
new RunGML_Op ("import",
	function(_i, _l) {
		if !file_exists(_l[0]) return [];
		var _file = file_text_open_read(_l[0]);
		var _json_string = "";
		while (!file_text_eof(_file)) {
			_json_string += file_text_read_string(_file);
			file_text_readln(_file);
		}
		file_text_close(_file);
		return json_parse(_json_string);
	},
@"Import JSON from a file
    - args: [filepath]
    - output: json",
	[new RunGML_Constraint_ArgType(0, "string")]
)
	
new RunGML_Op ("runfile",
	function(_i, _l) {
		return _i.run([
			["run", ["import", _l[0]]]
		])
	},
@"Run a program from a file
    - args: [filepath]
    - output: *",
	[new RunGML_Constraint_ArgType(0, "string")]
)
	
new RunGML_Op ("runprog",
	function(_i, _l) {
		return _i.run([
			["run", ["import", ["string", "RunGML/programs/{0}.json", _l[0]]]]
		])
	},
@"Run a program from a file in the incdlued RunGML/programs directory
    - args: [program_name]
    - output: *",
	[new RunGML_Constraint_ArgType(0, "string")]
)
	
new RunGML_Op ("example",
	function(_i, _l) {
		return _i.run(["run", ["import", ["string", "RunGML/programs/examples/{0}.json", _l[0]]]])
	},
@"Run an included example program
    - args: [example_program_name]
    - output: *",
	[new RunGML_Constraint_ArgType(0, "string")]
)
	
new RunGML_Op ("export",
	function(_i, _l) {
		var _file = file_text_open_write(_l[0]);
		var _pretty = true;
		if array_length(_l) > 2 {
			_pretty = _l[2];	
		}
		var _json_string = json_stringify(_l[1], _pretty);
		file_text_write_string(_file, _json_string);
		file_text_close(_file);
		return []
	},
@"Export JSON to a file
    - args: [path, data, (pretty=true)]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "string"),
		new RunGML_Constraint_ArgType(1, ["array", "struct"]),
		new RunGML_Constraint_ArgType(2, "bool", false),
	]
)
	
new RunGML_Op ("list",
	function(_i, _l=[]) {
		return _l;
	},
@"Return arguments as a list
    - args: []
    - output: []"
)
	
new RunGML_Op ("prog",
	function(_i, _l=[]) {
		for (var _line=0; _line<array_length(_l); _line++) {
			_i.run(_l[_line]);
		}
		return [];
	},
@"Run arguments as programs
    - args: []
    - output: []",
	[new RunGML_Constraint_ArgType(0, "array")]
)
	
new RunGML_Op("if",
	function(_i, _l) {
		if(_l[0]) {
			if struct_exists(_l[1], "true") {
				_i.run(struct_get(_l[1], "true"));
			}
		} else if struct_exists(_l[1], "false") {
			_i.run(struct_get(_l[1], "false"));
		}
	},
@"Evaluate and act on a conditional
    - args: [conditional {'true': program, 'false': program}]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "bool"),
		new RunGML_Constraint_ArgType(1, "struct"),
	]
)
	
new RunGML_Op("switch",
	function(_i, _l) {
		// value, case_dict
		if struct_exists(_l[1], _l[0]){
			_i.run(struct_get(_l[1], _l[0]));	
		} else if struct_exists(_l[1], "default") {
			_i.run(struct_get(_l[1], "default"));
		}
	},
@"Perform switch/case evaluation
    - args: [value, {'case0': program, 'case1': program, 'default': program}]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType(1, "struct")
	]
)
	
new RunGML_Op("while",
	function(_i, _l) {
		// condition, func
		var _check = struct_get(_l[0], "check")
		var _f = struct_get(_l[0], "do")
		while(true) {
			if _i.run(RunGML_clone(_check)) {
				_i.run(RunGML_clone(_f));
			} else break;
		}
	},
@"Exectue a function while a condition is true
    - args: [{'check': program, 'do': program}]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "struct")
	]
)
	
new RunGML_Op("repeat",
	function(_i, _l) {
		// count, func
		for (var i=0; i<_l[0]; i++) {
			_i.run(struct_get(_l[1], "do"));
		}
	},
@"Repeat a function a fixed number of times
    - args: [count, program]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "list")
	]
)

#endregion Control Flow
	
#region Debugging

new RunGML_Op ("print",
	function(_i, _l) {
		for(var i=0; i<array_length(_l); i++) {
			show_debug_message(string(_l[i]));
		}
		return [];
	},
@"Print a debug message
    - args: [stringable, (...)]
    - output: []"
)

#endregion Debugging
	
#region Strings

new RunGML_Op ("string",
	function(_i, _l) {
		var _s = array_shift(_l);
		return string_ext(_s, _l);
	},
@"Format a string
    - args: [template, (var0), ...]
    - output: [string]",
	[new RunGML_Constraint_ArgType(0, "string")]
)

new RunGML_Op ("cat",
	function(_i, _l) {
		var _out = "";
		for (var i=0; i<array_length(_l); i++) {
			_out += string(_l[i]);	
		}
		return _out;
	},
@"Concatenate arguments into a single string
    - args: [value, (...)]
    - output: [string]",
)

#endregion Strings
		
#region Accessors
new RunGML_Op ("var",
	function(_i, _l) {
		if array_length(_l) == 0 return _i.registers;
		else if array_length(_l) == 1 {
			if struct_exists(_i.registers, _l[0]) {
				return struct_get(_i.registers, _l[0]);
			}
			else return undefined;
		} else {
			struct_set(_i.registers, _l[0], _l[1]);
			return [];
		}
	},
@"Get and set variables.  Behavior changes based on number of arguments:
        - 0: Returns the interpreter's entire registers struct.
        - 1: Returns the value saved in the named register.
        - 2: Sets the register named by the first argument to the value of the second argument.
    - args: [int] or [string]
    - output: *"
)
	
new RunGML_Op ("reference",
	function(_i, _l) {
		if array_length(_l) == 0 return _i.registers;
		if struct_exists(_i.ops, _l[0]) {
			for (var i=1; i<array_length(_l); i++) {
				if struct_exists(_i.registers, _l[i]) {
					_l[i] = struct_get(_i.registers, _l[i]);
				}
			}
			return _i.run(_l);
		}
		else return undefined;
	},	
@"Operate on referenced values.  Behavior depends on the number of arguments:
        - 0: Return the interpreter's registers struct (same as ['v'])
        - 1+: If the first argument names an operator:
            - Substitute any other arguments that name defined reigsters with their values.
            - Run the first-argument operator on the resulting list of substituted arguments.
            - For example, the following two programs are functionally equivalent:
                - ['r', 'add', 'foo', 'bar']
                - ['add', ['v', 'foo'], ['v', 'bar']]
            - They will return the sum of the values in registers 'foo' and 'bar'.
    - args: [(operator), (register_name, ...)]
    - output: *"
)

new RunGML_Op ("reference_parent",
	function(_i, _l) {
		if array_length(_l) == 0 return variable_instance_get_names(_i.parent);
		if struct_exists(_i.ops, _l[0]) {
			for (var i=1; i<array_length(_l); i++) {
				if variable_instance_exists(_i.parent, _l[i]) {
					_l[i] = variable_instance_get(_i.parent, _l[i]);
				}
			}
			return _i.run(_l);
		}
		else return undefined;
	},	
@"Similar to the 'reference' ('r') operator, but substitutes with values from the parent's instance variables.  Behavior depends on the number of arguments:
        - 0: Return the names of all parent instance variables
        - 1+: If the first argument names an operator:
            - Substitute any other arguments that name parent instance variables with their values
            - Run the first-argument operator on the resulting list of substituted arguments.
            - For example, the following two programs are functionally equivalent:
                - ['rp', 'add', 'foo', 'bar']
                - ['add', ['p', 'foo'], ['p', 'bar']]
            - They will return the sum of the values in parent instance variables 'foo' and 'bar'.
    - args: [(operator), (variable, ...)]
    - output: *"
)
	
new RunGML_Op("global",
	function(_i, _l) {
		switch(array_length(_l)) {
			case 0:
				return variable_instance_get_names(global);
				break;
			case 1: 
				return variable_global_get(_l[0]);
				break;
			case 2:
			default:
				variable_global_set(_l[0], _l[1]);
				return [];
				break;
		}
	},
@"Create, read, or modify global variables. Behavior depends on the number of arguments:
        - 0: return an empty struct
        - 1: returns {'struct': arg0}
        - 2: returns get_struct(arg0, arg1)
    - args: []
    - output: []"
)
	
new RunGML_Op("inst",
	function(_i, _l) {
		switch(array_length(_l)) {
			case 1:
				return variable_instance_get_names(_l[0]);
				break;
			case 2:
				return variable_instance_get(_l[0], _l[1]);
				break;
			case 3:
				variable_instance_set(_l[0], _l[1], _l[2]);
				return [];
				break;
			default:
				return undefined;
				break;
		}
	},
@"Get and set instance variables. Behavior depends on the number of arguments:
        - 2: returns variable_instance_get(arg0, arg1)
        - 3: does variable_instance_set(arg0, arg1, arg2)
    - args: [instance, index, (value)]
    - output: *"
)
	
new RunGML_Op("struct",
	function(_i, _l) {
		// struct, variable
		switch(array_length(_l)) {
			case 0:
				return {}
				break;
			case 1: 
				return {"struct": _l}
				break;
			case 2:
				return struct_get(_l[0], _l[1]);
				break;
			case 3:
			default:
				struct_set(_l[0], _l[1], _l[2]);
				return [];
				break;
		}
	},
@"Create, read, or modify a struct. Behavior depends on the number of arguments:
        - 0: return an empty struct
        - 1: returns {'struct': arg0}
        - 2: returns get_struct(arg0, arg1)
        - 3: returns set_struct(arg0, arg1, arg2);
    - args: []
    - output: []"
)
	
new RunGML_Op("struct_keys",
	function(_i, _l) {
		// struct, variable
		return struct_get_names(_l[0]);
	},
@"Get a list of the keys in a struct
    - args: [struct]
    - output: [string, ...]"
)

new RunGML_Op("array",
	function(_i, _l) {
		// (array), (index), (value)
		switch(array_length(_l)) {
			case 0:
				return [];
				break;
			case 1: 
				return _l;
				break;
			case 2:
				if _l[1] < array_length(_l[0]) return undefined;
				return _l[0][_l[1]];
				break;
			case 3:
			default:
				while array_length(_l[0]) <= _l[1] {
					array_push(_l[0], undefined);
				}
				_l[0][_l[1]] = _l[2];
				return [];
				break;
		}
	},
@"Create, read, or modify a struct. Behavior depends on the number of arguments:
        - 0: return an empty array
        - 1: returns [arg0]
        - 2: returns arg0[arg1]
        - 3: sets arg0[arg1] = arg2;
    - args: [(array), (index), (value)]
    - output: [*]"
)

new RunGML_Op("array_get",
	function(_i, _l) {
		if (_l[1] < 0) or (_l[1] >= array_length(_l[0])) return undefined;
		var _arr = _l[0];
		var _index = _l[1];
		return _arr[_index];
	},
@"Return a value from an array by index.
    - args: [array, index]
    - output: value",
	[
		new RunGML_Constraint_ArgType(0, "array"),
		new RunGML_Constraint_ArgType(1, "numeric"),
	]
)
	
new RunGML_Op("len",
	function(_i, _l) {
		// struct, variable
		switch(typeof(_l[0])) {
			case "struct":
				return struct_names_count(_l[0]);
			case "array":
				return array_length(_l[0]);
			case "string":
				return string_length(_l[0]);
			default:
				return undefined;
		}
	},
@"Returns the length of a string, array, or struct.
    - args: [string/array/struct]
    - output: length"
)

#endregion Accessors

#region Math

new RunGML_Op("add",
	function(_i, _l) {
		// a, b
		return _l[0] + _l[1];
	},
@"Add two or more numbers (use 'cat' or 'string' to combine strings)
    - args: [A, B]
    - output: A + B (+ ...)",
	[
		new RunGML_Constraint_ArgCount("geq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("inc",
	function(_i, _l) {
		// a, b
		if struct_exists(_i.registers, _l[0]) {
			struct_set(_i.registers, _l[0], struct_get(_i.registers, _l[0]) + _l[1])
		} else {
			struct_set(_i.registers, _l[0], _l[1]);
		}
		return [];
	},
@"Increment a variable by some amount.  If the variable is undefined, set it to that amount.
    - args: [register_name, number]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType(0, "alphanumeric"),
		new RunGML_Constraint_ArgType(1, "numeric")
	]
)

new RunGML_Op("dec",
	function(_i, _l) {
		// a, b
		if struct_exists(_i.registers, _l[0]) {
			struct_set(_i.registers, _l[0], struct_get(_i.registers, _l[0]) - _l[1])
		} else {
			struct_set(_i.registers, _l[0], _l[1]);
		}
		return [];
	},
@"Decrement a variable by some amount.  If the variable is undefined, set it to that amount.
    - args: [register_name, number]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType(0, "alphanumeric"),
		new RunGML_Constraint_ArgType(1, "numeric")
	]
)
	
new RunGML_Op("sub",
	function(_i, _l) {
		// a, b
		return _l[0] - _l[1];	
	},
@"Subtract two numbers
    - args: [A, B]
    - output: A - B",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)
	
new RunGML_Op("mult",
	function(_i, _l) {
		// a, b
		return _l[0] * _l[1];	
	},
@"Multiply two numbers
    - args: [A, B]
    - output: A * B",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)
	
new RunGML_Op("div",
	function(_i, _l) {
		//a, b
		return _l[0] / _l[1];	
	},
@"Divide two numbers
    - args: [A, B]
    - output: A / B",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)
	
new RunGML_Op("pow",
	function(_i, _l) {
		return power(_l[0], _l[1]);
	},
@"Raise one number to the power of another
    - args: [A, B]
    - output: A ^ B",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("exp",
	function(_i, _l) {
		return exp(_l[0]);
	},
@"Raise e to some power
    - args: [number]
    - output: e ^ number",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("log",
	function(_i, _l) {
		if array_length(_l) == 1 {
			return log10(_l[0]);
		} else return logn(_l[1], _l[0]);
	},
@"Compute a logarithm.  Behavior depends on the number of arguments:
        - 0: Return the log of the argument in base 10
		- 1: Return the log of arg0 in the base of arg1
    - args: [number, (base=10)]
    - output: log_base(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric", false)
	]
)

new RunGML_Op("mod",
	function(_i, _l) {
		return _l[0] mod _l[1];
	},
@"Modulo operator
    - args: [A, B]
    - output: A mod B",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("min",
	function(_i, _l) {
		return min(_l[0], _l[1]);
	},
@"Return the smaller of two numbers
    - args: [A, B]
    - output: min(A, B)",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("max",
	function(_i, _l) {
		return max(_l[0], _l[1]);
	},
@"Return the larger of two numbers
    - args: [A, B]
    - output: max(A, B)",
	[
		new RunGML_Constraint_ArgCount("eq", 2),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("round",
	function(_i, _l) {
		return round(_l[0]);
	},
@"Rounds a number
    - args: [number]
    - output: round(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("floor",
	function(_i, _l) {
		return floor(_l[0]);
	},
@"Rounds a number down
    - args: [number]
    - output: floor(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("ceil",
	function(_i, _l) {
		return ceil(_l[0]);
	},
@"Rounds a number up
    - args: [number]
    - output: ceil(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("frac",
	function(_i, _l) {
		return frac(_l[0]);
	},
@"Returns the fractional portion of a number
    - args: [number]
    - output: frac(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("sign",
	function(_i, _l) {
		return sign(_l[0]);
	},
@"Returns the sign of a number (1 if positive, -1 if negative)
    - args: [number]
    - output: sign(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)

new RunGML_Op("abs",
	function(_i, _l) {
		return abs(_l[0]);
	},
@"Returns the absolute value of a number
    - args: [number]
    - output: abs(number)",
	[
		new RunGML_Constraint_ArgType(0, "numeric")
	]
)
	
new RunGML_Op("clamp",
	function(_i, _l) {
		return clamp(_l[0], _l[1], _l[2]);
	},
@"Clamp a number between a minimum and maximum value
    - args: [number, min, max]
    - output: number",
	[
		new RunGML_Constraint_ArgCount("eq", 3),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("lerp",
	function(_i, _l) {
		return lerp(_l[0], _l[1], _l[2]);
	},
@"Lerp between two numbers by a given amount
    - args: [min, max, fraction]
    - output: number",
	[
		new RunGML_Constraint_ArgCount("eq", 3),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("map_range",
	function(_i, _l) {
		return (_l[0] - _l[1]) * (_l[4] - _l[3]) / (_l[2] - _l[1]) + _l[3];
	},
@"Map a value proportionally from one range to another
    - args: [number, in_min, in_max, out_min, out_max]
    - output: number",
	[
		new RunGML_Constraint_ArgCount("eq", 5),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)
	
new RunGML_Op("approach",
	function(_i, _l) {
		var _val = _l[0] + _l[1];
		_val = clamp(_val, _l[2], _l[3]);
		return _val;
	},
@"Increment a number by some amount while staying within a range
    - args: [number, increment, min, max]
    - output: [number]",
	[
		new RunGML_Constraint_ArgCount("eq", 4),
		new RunGML_Constraint_ArgType("all", "numeric")
	]
)

new RunGML_Op("rand",
	function(_i, _l) {
		var _min = 0;
		var _max = 1;
		if array_length(_l) == 1 _max = _l[0]
		else if array_length(_l) == 2 {
			_min = _l[0]
			_max = _l[1]
		}
		return random_range(_min, _max);
	},
@"Return a random value.  Behavior depends on the number of arguments:
        - 0: Return a value between 0 and 1 (inclusive)
		- 1: Return a value between 0 and arg0 (inclusive)
		- 2: Return a value between arg0 and arg1 (inclusive)
    - args: [(max=1)]
    - output: number",
	[
		new RunGML_Constraint_ArgType(0, "numeric", false),
		new RunGML_Constraint_ArgType(1, "numeric", false),
	]
)
new RunGML_Op("rand_int",
	function(_i, _l) {
		var _min = 0;
		var _max = 1;
		if array_length(_l) == 1 _max = _l[0]
		else if array_length(_l) == 2 {
			_min = _l[0]
			_max = _l[1]
		}
		return irandom_range(_min, _max);
	},
@"Return a random integer.  Behavior depends on the number of arguments:
        - 0: Return either 0 or 1
		- 1: Return an integer between 0 and arg0 (inclusive)
		- 2: Return an integer between arg0 and arg1 (inclusive)
    - args: [(max=1)]
    - output: number",
	[
		new RunGML_Constraint_ArgType(0, "numeric", false),
		new RunGML_Constraint_ArgType(1, "numeric", false),
	]
)

new RunGML_Op("rand_seed",
	function(_i, _l) {
		if array_length(_l) > 0 random_set_seed(_l[0]);
		else randomise();
	},
@"Return a random value between 0 and some upper limit (defaults to 1).  Inclusive on both ends.
    - args: [(max=1)]
    - output: number",
	[
		new RunGML_Constraint_ArgType(0, "numeric", false)
	]
)

new RunGML_Op("choose",
	function(_i, _l) {
		var _index = irandom_range(0, array_length(_l[0])-1);
		return _l[0][_index]
	},
@"Return a random element from a list.
    - args: [(max=1)]
    - output: number",
	[
		new RunGML_Constraint_ArgType(0, "array")
	]
)

#endregion Math
	
#region Objects

new RunGML_Op("object",
	function(_i, _l) {
		var _inst;
		if typeof(_l[2]) == "string" {
			_inst = instance_create_layer(_l[0], _l[1], _l[2], oRunGML_ObjectTemplate);
		} else {
			_inst = instance_create_depth(_l[0], _l[1], _l[2], oRunGML_ObjectTemplate);
		}
		_inst.event_dict = _l[3]
		_inst.run_event("create")
		return _inst;
	},
@"Create a new oRunGML_Object instance and return its index
    - args: [x, y, depth/layer_name, event_dictionary]
    - output: oRunGML_Object instance",
	[
		new RunGML_Constraint_ArgCount("eq", 4),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "alphanumeric"),
		new RunGML_Constraint_ArgType(3, "struct")
	]
)
	
new RunGML_Op("create",
	function(_i, _l) {
		// x, y, layer, object_index
		if typeof(_l[3]) == "string" {
			_l[3] = asset_get_index(_l[3])
		}
		if typeof(_l[2]) == "string" {
			return instance_create_layer(_l[0], _l[1], _l[2], _l[3]);
		} else {
			return instance_create_depth(_l[0], _l[1], _l[2], _l[3]);
		}
	},
@"Create a new object instance
    - args: [x, y, depth/layer_name, object_name]
    - output: [instance_id]"
	,
	[
		new RunGML_Constraint_ArgCount("eq", 4),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "alphanumeric"),
		new RunGML_Constraint_ArgType(3, "alphanumeric")
	]
)
	
new RunGML_Op("destroy",
	function(_i, _l) {
		instance_destroy(_l[0]);
	},
@"Destroy an instance
    - args: [instance_id]
    - output: []"
)

#endregion Objects
	
#region Logic

new RunGML_Op("and",
	function(_i, _l) {
		return _l[0] and _l[1];	
	},
@"Logical and operator
    - args: [A, B]
    - output: A and B"
)
	
new RunGML_Op("or",
	function(_i, _l) {
		return _l[0] or _l[1];	
	},
@"Logical or operator
    - args: [A, B]
    - output: [(A or B)]"
)
	
new RunGML_Op("not",
	function(_i, _l) {
		return not _l[0];
	},
@"Return the inverse of the argument's boolean value
    - args: [A]
    - output: [!A]"
)
	
new RunGML_Op("eq",
	function(_i, _l) {
		return _l[0] == _l[1];	
	},
@"Check whether two arguments are equivalent
    - args: [A, B]
    - output: [(A == B)]"
)

new RunGML_Op("neq",
	function(_i, _l) {
		return _l[0] != _l[1];	
	},
@"Check whether two arguments are not equal (inverse of 'eq')
    - args: [A, B]
    - output: [(A != B)]"
)
	
new RunGML_Op("lt",
	function(_i, _l) {
		return _l[0] < _l[1];	
	},
@"Check whether the first argument is less than the second
    - args: [A, B]
    - output: [(A < B)]"
)
	
new RunGML_Op("gt",
	function(_i, _l) {
		return _l[0] > _l[1];	
	},
@"Check whether the first argument is greater than the second
    - args: [A, B]
    - output: [(A > B)]"
)
	
new RunGML_Op("leq",
	function(_i, _l) {
		return _l[0] <= _l[1];	
	},
@"Check whether the first argument is less than or equal to the second
    - args: [A, B]
    - output: [(A <= B)]"
)
	
new RunGML_Op("geq",
	function(_i, _l) {
		return _l[0] >= _l[1];	
	},
@"Check whether the first argument is greater than or equal to the second
    - args: [A, B]
    - output: [(A >= B)]"
)

#endregion Logic

#region Distance & Direction

new RunGML_Op("point_dist",
	function(_i, _l) {
		return point_distance(_l[0], _l[1], _l[2], _l[3]);
	},
@"Find the distance between two points
    - args: [x1, y1, x2, y2]
    - output: distance"
)

new RunGML_Op("point_dir",
	function(_i, _l) {
		return point_direction(_l[0], _l[1], _l[2], _l[3]);
	},
@"Find the direction from one point to another
    - args: [x1, y1, x2, y2]
    - output: distance"
)

new RunGML_Op("lendir_x",
	function(_i, _l) {
		return lengthdir_x(_l[0], _l[1]);
	},
@"Find the x component for a given vector
    - args: [length, direction]
    - output: x_component"
)

new RunGML_Op("lendir_y",
	function(_i, _l) {
		return lengthdir_y(_l[0], _l[1]);
	},
@"Find the y component for a given vector
    - args: [length, direction]
    - output: y_component"
)

#endregion Distance & Direction
	
#region Rooms

new RunGML_Op("room_w",
	function(_i, _l=[]) {
		//
		return room_width;	
	},
@"Returns the width of the current room.
    - args: []
    - output: [width]"
)
	
new RunGML_Op("room_h",
	function(_i, _l=[]) {
		//
		return room_height;
	},
@"Returns the height of the current room.
    - args: []
    - output: [height]"
)

new RunGML_Op("room",
	function(_i, _l=[]) {
		switch(array_length(_l)) {
			case 0:
				return room_get_name(room);
				break;
			case 1:
				var _room = asset_get_index(_l[0]);
				if !room_exists(_room) return -1;
				room_goto(_room);
				return [];
				break;
		}
	},
@"Behavior depends on the number of arguments:
        - 0: Return the name of the current room
		- 1: Go to the named room, if it exists
    - args: [(room_name)]
    - output: [(room_name)]"
)

new RunGML_Op("room_next",
	function(_i, _l=[]) {
		room_goto_next();
		return [];
	},
@"Go to the next room.
    - args: []
    - output: [height]"
)

#endregion Rooms
	
#region Displays

new RunGML_Op("display_w",
	function(_i, _l=[]) {
		//
		return display_get_width();	
	},
@"Returns the width of the display.
    - args: []
    - output: [width]"
)
	
new RunGML_Op("display_h",
	function(_i, _l=[]) {
		//
		return display_get_height();
	},
@"Returns the height of the display.
    - args: []
    - output: [height]"
)

new RunGML_Op("display_gui_w",
	function(_i, _l=[]) {
		//
		return display_get_gui_width();	
	},
@"Returns the width of the display GUI.
    - args: []
    - output: [width]"
)
	
new RunGML_Op("display_gui_h",
	function(_i, _l=[]) {
		//
		return display_get_gui_height();
	},
@"Returns the height of the display GUI.
    - args: []
    - output: [height]"
)

new RunGML_Op("fullscreen",
	function(_i, _l=[]) {
		//
		if array_length(_l) > 0 window_set_fullscreen(_l[0])
		else window_set_fullscreen(not window_get_fullscreen());
		return [];
	},
@"Toggle fullscreen mode.  Set status with a single boolean argument, or swap status with no arguments.
    - args: [(bool)]
    - output: []"
)

#endregion Displays
	
#region Drawing

new RunGML_Op("draw_text",
	function(_i, _l) {
		// x, y, string
		draw_text(_l[0], _l[1], _l[2]);
	},
@"Draw text
    - args: [x, y, string]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("eq", 3),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "string")
	]
)

new RunGML_Op("draw_sprite",
	function(_i, _l) {
		// sprite, frame, x, y
		draw_sprite(_l[0], _l[1], _l[2], _l[3]);
	},
@"Draw a sprite
    - args: [sprite_index, frame, x, y]
    - output: []"
)
	
new RunGML_Op("draw_sprite_general",
	function(_i, _l) {
		// sprite, frame, left, top, width, height, x, y, xscale, yscale, rot, c1, c2, c3, c4, alpha
		draw_sprite_general(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5], _l[6], _l[7], _l[8], _l[9], _l[10], _l[11], _l[12], _l[13], _l[14], _l[15])	
	},
@"Draw a sprite using additional parameters
    - args: [sprite_index, frame, left, top, width, height, x, y, xscale, yscale, rot, c1, c2, c3, c4, alpha]
    - output: []"
)

new RunGML_Op("draw_point",
	function(_i, _l) {
		if array_length(_l) > 2 {
			var _c = draw_get_color
			draw_set_color(_l[2]);
			draw_point(_l[0], _l[1])
			draw_set_color(_c);
		} else draw_point(_l[0], _l[1]);
	},
@"Draw a point
    - args: [x, y, (color)]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric", false),
	]
)

new RunGML_Op("draw_line",
	function(_i, _l) {
		var _c_center = draw_get_color();
		var _c_edge = _c_center;
		var _n_args = array_length(_l)
		if _n_args > 4 {
			_c_center = _l[4]
			if _n_args > 5 {
				_c_edge = _l[5]
			} else {
				_c_edge = _c_center
			}
		}
		draw_line_color(_l[0], _l[1], _l[2], _l[3], _c_center, _c_edge);
	},
@"Draw a line
    - args: [x1, y1, x2, y2, (color), (color2)]
    - output: []",
	[
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric"),
		new RunGML_Constraint_ArgType(3, "numeric"),
		new RunGML_Constraint_ArgType(4, "numeric", false),
		new RunGML_Constraint_ArgType(5, "numeric", false),
	]
)

new RunGML_Op("draw_circle",
	function(_i, _l) {
		var _r = 1;
		var _outline = false;
		var _c_center = draw_get_color();
		var _c_edge = _c_center;
		var _n_args = array_length(_l)
		if _n_args > 2 {
			_r = _l[2]
			if _n_args > 3 {
				_outline = _l[3]
				if _n_args > 4 {
					_c_center = _l[4]
					if _n_args > 5 {
						_c_edge = _l[5]
					} else {
						_c_edge = _c_center
					}
				}
			}
		}
		draw_circle_color(_l[0], _l[1], _r, _c_center, _c_edge, _outline);
	},
@"Draw a circle
    - args: [x, y, (r=1), (outline=false), (c_center=draw_color), (c_edge=draw_color)]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("in", [3, 4, 5, 6]),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric", false),
		new RunGML_Constraint_ArgType(3, "bool", false),
		new RunGML_Constraint_ArgType(4, "bool", false),
	]
)

new RunGML_Op("draw_ellipse",
	function(_i, _l) {
		var _outline = false;
		var _c_center = draw_get_color();
		var _c_edge = _c_center;
		var _n_args = array_length(_l)
		if _n_args > 4 {
			_outline = _l[4]
			if _n_args > 5 {
				_c_center = _l[5]
				if _n_args > 6 {
					_c_edge = _l[6]
				} else {
					_c_edge = _c_center
				}
			}
		}
		draw_ellipse_color(_l[0], _l[1], _l[2], _l[3], _c_center, _c_edge, _outline);
	},
@"Draw an ellipse
    - args: [x1, y1, x2, y2, (outline=false), (c_center=draw_color), (c_edge=draw_color)]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("in", [3, 4, 5, 6]),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric"),
		new RunGML_Constraint_ArgType(3, "numeric"),
		new RunGML_Constraint_ArgType(4, "bool", false),
		new RunGML_Constraint_ArgType(5, "numeric", false),
		new RunGML_Constraint_ArgType(6, "numeric", false),
	]
)

new RunGML_Op("draw_rect",
	function(_i, _l) {
		var _outline = false;
		var _c1, _c2, _c3, _c4 = draw_get_color()
		var _n_args = array_length(_l)
		if _n_args > 4 {
			_outline = _l[4]
			if _n_args > 5 {
				_c1 = _l[5];
				if _n_args > 6 {
					_c2 = _l[6];
					_c3 = _l[7];
					_c4 = _l[8];
				} else {
					_c2 = _c1;
					_c3 = _c1;
					_c4 = _c1;
				}
			}
		}
		draw_rectangle_color(_l[0], _l[1], _l[2], _l[3], _c1, _c2, _c3, _c4, _outline)
	},
@"Draw a rectangle
    - args: [x1, y1, x2, y2, (outline=false), (c1=draw_color), (c2=c1, c3=c1, c4=c1)]
    - output: []",
	[
		new RunGML_Constraint_ArgCount("in", [4, 5, 6, 9]),
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric"),
		new RunGML_Constraint_ArgType(3, "numeric"),
		new RunGML_Constraint_ArgType(4, "bool", false),
		new RunGML_Constraint_ArgType(5, "numeric", false),
		new RunGML_Constraint_ArgType(6, "numeric", false),
		new RunGML_Constraint_ArgType(7, "numeric", false),
		new RunGML_Constraint_ArgType(8, "numeric", false),
	]
)

new RunGML_Op("draw_color",
	function(_i, _l) {
		if array_length(_l) < 1 return draw_get_color();
		draw_set_color(_l[0]);
		return [];
	},
@"Get or set the draw color.
    - args: [(color)]
    - output: (color)",
	[new RunGML_Constraint_ArgType(0, "numeric", false)]
)
	
new RunGML_Op("draw_alpha",
	function(_i, _l) {
		if array_length(_l) < 1 return draw_get_alpha();
		draw_set_alpha(_l[0]);
		return [];
	},
@"Get or set the draw alpha.
    - args: [(alpha)]
    - output: (alpha)",
	[new RunGML_Constraint_ArgType(0, "numeric", false)]
)

new RunGML_Op("draw_font",
	function(_i, _l) {
		if array_length(_l) < 1 return draw_get_font();
		if typeof(_l[0]) == "string" {
			_l[0] = asset_get_index(_l[0]);
		}
		draw_set_font(_l[0]);
		return [];
	},
@"Get or set the draw font.
    - args: [(font)]
    - output: (font)",
	[new RunGML_Constraint_ArgCount("leq", 1)]
)
	
new RunGML_Op("draw_halign",
	function(_i, _l) {
		if array_length(_l) < 1 return draw_get_halign();	
		switch(_l[0]) {
			case "left":
			case fa_left:
			case -1:
				draw_set_halign(fa_left);
				break;
			case "right":
			case fa_right:
			case 1:
				draw_set_halign(fa_right);
				break;
			case "center":
			case fa_center:
			case 0:
				draw_set_halign(fa_center);
				break;
		}
		return [];
	},
@"Get or set the horizontal draw alignment
    - args: [(value)]
    - output: (value)"
)
	
new RunGML_Op("draw_valign",
	function(_i, _l) {
		if array_length(_l) < 1 {
			return draw_get_valign();	
		} else {
			switch(_l[0]) {
				case "top":
				case fa_top:
				case -1:
					draw_set_valign(fa_top);
					break;
				case "bottom":
				case fa_bottom:
				case 1:
					draw_set_valign(fa_bottom);
					break;
				case "middle":
				case fa_middle:
				case 0:
					draw_set_valign(fa_middle);
					break;
			}
			return [];
		}
	},
@"Get or set the vertical draw alignment
    - args: [(value)]
    - output: (value)"
)

new RunGML_Op("draw_format",
	function(_i, _l) {
		if array_length(_l) < 1 {
			var _format = [
				draw_get_font(),
				draw_get_halign(),
				draw_get_valign(),
				draw_get_color(),
				draw_get_alpha(),
			]
			return _format;
		}
		else {
			var _font = _l[0][0];
			if typeof(_font) == "string" {
				_font = asset_get_index(_font);
			}
			return _i.run(["pass",
				["draw_font", _font],
				["draw_halign", _l[0][1]],
				["draw_valign", _l[0][2]],
				["draw_color", _l[0][3]],
				["draw_alpha", _l[0][4]],
			])
		}
	},
@"Get or set the draw font, h_align, v_align, color, and alpha simultaneously.
    - args: [([font, h_align, v_align, color, alpha])]
    - output: ([font, h_align, v_align, color, alpha])",
	[new RunGML_Constraint_ArgCount("leq", 1)]
)
	
new RunGML_Op("rgb",
	function(_i, _l) {
		return make_color_rgb(_l[0], _l[1], _l[2]);	
	},
@"Create an RGB color
    - args: [red, green, blue]
    - output: color"
)
	
new RunGML_Op("hsv",
	function(_i, _l) {
		return make_color_hsv(_l[0], _l[1], _l[2]);	
	}, 
@"Create an HSV color
    - args: [hue, saturation, value]
    - output: color"
)

new RunGML_Op("color",
	function(_i, _l) {
		var _color;
		if struct_exists(global.RunGML_Colors, _l[0]) {
			_color = struct_get(global.RunGML_Colors, _l[0])
		} else if string_length(_l[0]) == 6 {
			var _r = string_concat("0x", string_char_at(_l[0], 1), string_char_at(_l[0], 2))
			var _g = string_concat("0x", string_char_at(_l[0], 3), string_char_at(_l[0], 4))
			var _b = string_concat("0x", string_char_at(_l[0], 5), string_char_at(_l[0], 6))
			_color =  make_color_rgb(real(_r), real(_g), real(_b));
		}
		return _color;
	}, 
@"Create a color by name or hex code
    - args: [string]
    - output: color",
	[new RunGML_Constraint_ArgType(0, "string")]
)

new RunGML_Op("color_merge",
	function(_i, _l) {
		return merge_color(_l[0], _l[1], _l[2]);
	},
@"Merge two colors by some amount
    - args: [color1, color2, fraction]
    - output: color3",
	[
		new RunGML_Constraint_ArgType(0, "numeric"),
		new RunGML_Constraint_ArgType(1, "numeric"),
		new RunGML_Constraint_ArgType(2, "numeric")
	]
)

new RunGML_Op("color_rand",
	function(_i, _l) {
		return random_range(0, 16777216);
	},
@"Create a random color
    - args: []
    - output: color",
)

new RunGML_Op("color_inv",
	function(_i, _l) {
		//return 16777216 - _l[0];
		var _r = color_get_red(_l[0]);
		var _g = color_get_green(_l[0]);
		var _b = color_get_blue(_l[0]);
		return make_color_rgb(255-_r, 255-_g, 255-_b);
	},
@"Create a random color
    - args: []
    - output: color",
)
	
#endregion Drawing

#region Shaders

new RunGML_Op ("shader",
	function(_i, _l=[]) {
		switch(array_length(_l)){
			case 0:
				shader_current();
				return [];
			case 1:
				var _sh = _l[1];
				if typeof(_sh) == "string" _sh = asset_get_index(_sh);
				shader_set(_sh)
				return []
		}
	},
@"Get or set the current shader. Zero arguments to get, one to set.
    - args: [(shader)]
    - output: [(shader)]",
	[
		new RunGML_Constraint_ArgType(0, "alphanumeric", false)
	]
)

new RunGML_Op ("shader_reset",
	function(_i, _l=[]) {
		shader_reset();
	},
@"Clear shaders
    - args: []
    - output: []"
)

//new RunGML_Op ("shader_uniform_f",
//	function(_i, _l=[]) {
//		var _sh = _l[0]
//		if typeof(_sh) == "string" _sh = asset_get_index(_sh);
//		var _u = _l[1]
//		switch(array_length(_l)){
//			case 2:
//				return shader_get_uniform(_sh, _u)
//			case 3:
//				switch_typof(
//				shader_set_uniform_f(_sh, _u, _
//				return [];
//		}
//	},
//@"Set the current shader.  Pass zero arguments to reset.
//    - args: [(shader)]
//    - output: []"
//)

#endregion Shaders

#region Time
new RunGML_Op("delta",
	function(_i, _l) {
		return delta_time / 1000000.0;
	},
@"Return the time elapsed since the previous frame in seconds
    - args: []
    - output: number"
)

new RunGML_Op("fps",
	function(_i, _l) {
		return fps;
	}, 
@"Get the current fps (capped at the room speed)
    - args: []
    - output: fps"
)
	
new RunGML_Op("fps_real",
	function(_i, _l) {
		return fps_real;
	}, 
@"Get the current fps (not capped at the room speed)
    - args: []
    - output: fps_real"
)
	
new RunGML_Op("game_speed",
	function(_i, _l) {
		if array_length(_l) > 0 {
			game_set_speed(_l[0], gamespeed_fps);
			return [];
		} else return game_get_speed(gamespeed_fps);
	}, 
@"Get or set the game speed in terms of fps
    - args: [(game_speed)]
    - output: (game_speed)"
)

#endregion Time

#region Network
new RunGML_Op("url_open",
	function(_i, _l=[]) {
		if string_copy(_l[0], 1, 3) == "www" {
			_l[0] = string("http://{0}", _l[0])
		}
		url_open(_l[0]);
		return [];
	},
@"Open a URL in the default browser
    - args: [URL]
    - output: []",
	[new RunGML_Constraint_ArgType(0, "string")]
)
#endregion Network

#region Misc

new RunGML_Op("nth",
	function(_i, _l) {
		var _n = abs(_l[0])
		var _mod100 = _n mod 100
		if _mod100 >= 4 and _mod100 <= 20 {
			return "th";
		}
		
		switch(_n mod 10){
			case 1:
				return "st";
			case 2:
				return "nd";
			case 3:
				return "rd";
			default:
				return "th";
		}
	},
@"Get the ordinal suffix for a given number
    - args: [number]
    - output: 'st', 'nd', 'rd', or 'th'"
)
	
new RunGML_Op("quit",
	function(_i, _l) {
		game_end();
		return [];
	}, 
@"Quit the game
    - args: []
    - output: []"
)

new RunGML_Op("asset",
	function(_i, _l) {
		return asset_get_index(_l[0])
	},
@"Return the index of the named asset
    - args: [asset_name]
    - output: index",
	[new RunGML_Constraint_ArgType(0, "string")]
)

new RunGML_Op("cursor",
	function(_i, _l) {
		return [mouse_x, mouse_y]
	},
@"Return the cursor's coordinates
    - args: []
    - output: [mouse_x, mouse_y]"
)

new RunGML_Op("near_cursor",
	function(_i, _l) {
		var _obj = all;
		if array_length(_l) > 0 {
			if typeof(_l[0]) == "string" _obj = asset_get_index(_l[0])
			else _obj = _l[0];
		}
		return instance_nearest(mouse_x, mouse_y, _obj);
	},
@"Return index of instance nearest to the mouse.  Optional argument specifies an object index or asset name.
    - args: [(object_index/asset_name)]
    - output: index",
	[new RunGML_Constraint_ArgType(0, "alphanumeric", false)]
)

new RunGML_Op("near",
	function(_i, _l) {
		var _x = mouse_x;
		var _y = mouse_y;
		var _obj = all;
		if array_length(_l) > 0 {
			_x = _l[0];
		} if array_length(_l) > 1 {
			_y = _l[1];
		}
		if array_length(_l) > 2 {
			if typeof(_l[2]) == "string" _obj = asset_get_index(_l[0])
			else _obj = _l[2];
		}
		return instance_nearest(_x, _y, _obj);
	},
@"Return index of instance (arg2) nearest to some coordinates (arg0, arg1).
    - args: [(x=mouse_x), (y=mouse_y), (obj=any)]
    - output: index",
	[
		new RunGML_Constraint_ArgType(0, "numeric", false),
		new RunGML_Constraint_ArgType(0, "numeric", false),
		new RunGML_Constraint_ArgType(0, "alphanumeric", false)
	]
)

new RunGML_Op("rickroll",
	function(_i, _l) {
		url_open("https://sdlwdr.github.io/rickroll/rickroll.mp4");
		return [];
	},
@"Got 'em!
    - args: []
    - output: []"
)

new RunGML_Op ("test_constant", 23);
#endregion Misc

#region Aliases
// "e" reserved for mathematical constant
RunGML_alias("g", "global");
RunGML_alias("i", "inst");
RunGML_alias("o", "object");
RunGML_alias("p", "parent");
RunGML_alias("q", "quit");
RunGML_alias("r", "reference");
RunGML_alias("rp", "reference_parent");
RunGML_alias("t", "this");
RunGML_alias("v", "var");

RunGML_alias("multiply", "mult");
RunGML_alias("subtract", "sub");
RunGML_alias("divide", "div");
RunGML_alias("True", "true");
RunGML_alias("False", "false");
#endregion Aliases

RunGML_ConfigOps();
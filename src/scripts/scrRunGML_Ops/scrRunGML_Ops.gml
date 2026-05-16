/* Operator Definitions
Additional operators should be defined in scrRunGML_Config
Make a backup of that file before updating RunGML
Then you can restore your custom settings and operators after updating
*/

function RunGML_DefineOps(_wipe=true) {
	if _wipe global.RunGML_Ops = {}
	
	#region Constants
	RunGML_DefineConstants();
	#endregion Constants

	#region Metadata

	new RunGML_Op("update",
		function(_i, _l=[]) {
			url_open(RunGML_Homepage);
			return [];
		},
	@"Open the RunGML homepage in the browser
	- args: []
	- output: string",
		[new RunGML_Constraint_ArgCount("eq", 0)]
	)
	
	new RunGML_Op("op_count",
		function(_i, _l=[]) {
			return struct_names_count(_i.ops);
		},
	@"Return the number of supported operators
	- args: []
	- output: number",
		[new RunGML_Constraint_ArgCount("eq", 0)]
	)
	
	new RunGML_Op("op_list",
		function(_i, _l=[]) {
			var _op_list = struct_get_names(_i.ops);
			array_sort(_op_list, true);
			
			var _include_constants = false;
			if array_length(_l) > 0 _include_constants = _l[0];
			if not _include_constants {
				var _out = [];
				var _n_ops = array_length(_op_list);
				var _op_name, _op;
				for (var i=0; i<_n_ops; i++) {
					_op_name = _op_list[i];
					_op = struct_get(_i.ops, _op_name);
					if _op.is_constant() continue;
					array_push(_out, _op_name);
				}
				return _out;
			} else return _op_list;
		},
	@"Return a list of supported operators
	- args: [(include_constants=false)]
	- output: [string, *]",
		[new RunGML_Constraint_ArgType(0, "bool", false)]
	)
	
	new RunGML_Op("op_names",
		function(_i, _l=[]) {
			var _op_list = struct_get_names(_i.ops);
			array_sort(_op_list, true);
			
			var _include_constants = false;
			if array_length(_l) > 0 _include_constants = _l[0];
			if not _include_constants {
				var _out = [];
				var _n_ops = array_length(_op_list);
				var _op_name, _op;
				for (var i=0; i<_n_ops; i++) {
					_op_name = _op_list[i];
					_op = struct_get(_i.ops, _op_name);
					if _op.is_constant() continue;
					array_push(_out, _op_name);
				}
				return _out;
			} else {
				_out = _op_list;
			}
			
			var _str = "";
			var _op_count = array_length(_out)
			for (var i=0; i<_op_count; i++) {
				if i > 0 _str += ", ";
				_str += _out[i];
			}
			return _str;
		},
	@"Return a string listing names of supported operators
	- args: [(include_constants)]
	- output: string",
		[new RunGML_Constraint_ArgType(0, "bool", false)]
	)
	
	new RunGML_Op("op_search",
		function(_i, _l=[]) {
			var _op_list = array_concat(struct_get_names(_i.ops), struct_get_names(_i.aliases));
			var _valid = [];
			var _count = array_length(_op_list);
			var _op_name;
			for (var i=0; i<_count; i++) {
				_op_name = _op_list[i];
				if string_pos(_l[0], _op_name) > 0 {
					array_push(_valid, _op_name);
				}
			}
			array_sort(_valid, true);
			return _valid;
		},
	@"Return a list of operators whose names contain a give string.
	- args: [string]
	- output: [string, *]",
		[new RunGML_Constraint_ArgCount("eq", 1)]
	)
	
	new RunGML_Op("help",
		function(_i, _l=[]) {
			if array_length(_l) > 0 {
				var _op_name = _l[0];
				while struct_exists(_i.aliases, _op_name) {
					// While to allow for nested aliases
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
	- args: [(op_name)]
	- output: doc_string", 
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
			file_text_write_string(_f, string(@"# RunGML Manual
			
## About

Version: {0}

Homepage: {1}
",
				RunGML_Version,
				RunGML_Homepage
			));
			
			file_text_write_string(_f, @"
## Table of Contents

- [Operator List](#operator-list)
- [Alias Definitions](#alias-definitions)
- [Operator Documentation](#operator-documentation)
- [Constant Definitions](#constant-definitions)
"
			);
			
			
			file_text_write_string(_f, "\n\n## Operator List\n");
			var _str = "";
			var _op_count = array_length(_ops)
			var _constants = [];
			var _function_ops = [];
			var _did_first = false;
			for (var i=0; i<_op_count; i++) {
				_op_name = _ops[i];
				//if struct_exists(_i.ops, _op_name) {
				_op = struct_get(_i.ops, _op_name);
				if _op.is_constant() {
					array_push(_constants,[_op_name, _op.f]);
					continue;
				}
				_str = string("[{0}]({1})", _op_name, string("#{0}", string_lower(_op.name)))
				if _did_first _str = string_concat(", ", _str)
				_did_first = true;
				file_text_write_string(_f, _str)
			}
		
			file_text_write_string(_f, "\n\n## Alias Definitions");
			var _alias_names = variable_struct_get_names(_i.aliases)
			var _primary_alias_names = [];
			var _points_to = [];
			var _n_aliases = array_length(_alias_names);
			var _nickname, _name;
			for (var i=0; i<_n_aliases; i++) {
				_nickname = _alias_names[i];
				_name = struct_get(_i.aliases, _nickname);
				array_push(_points_to, _name);
			}
			for (var i=0; i<_n_aliases; i++) {
				_nickname = _alias_names[i];
				if array_contains(_points_to, _nickname) continue;
				_name = struct_get(_i.aliases, _nickname);
				array_push(_primary_alias_names, _nickname);
			}
			array_sort(_primary_alias_names, true);
			var _alias_defs = "";
			_n_aliases = array_length(_primary_alias_names);
			for (var i=0; i<_n_aliases; i++) {
				_nickname = _primary_alias_names[i];
				_alias_defs += $"\n- {_nickname}";
				while(struct_exists(_i.aliases, _nickname)) {
					_name = struct_get(_i.aliases, _nickname);
					_alias_defs += $" -> {_name}";
					_nickname = _name;
				}
			}
			file_text_write_string(_f, _alias_defs);
			
			file_text_write_string(_f, "\n\n## Operator Documentation\n");

			for (var i=0; i<_op_count; i++) {
				_op_name = _ops[i];
				if !struct_exists(_i.ops, _op_name) continue;
				_op = struct_get(_i.ops, _op_name)
				if _op.is_constant() continue;
				file_text_write_string(_f, "\n"+_op.help()+"\n")
			}
			
			file_text_write_string(_f, "\n\n## Constant Definitions\n");
			var _const_count = array_length(_constants);
			var _const_name, _const_value;
			for (var i=0; i<_const_count; i++) {
				_const_name = _constants[i][0];
				_const_value = _constants[i][1];
				file_text_write_string(_f, $"\n- {_const_name} = {RunGML_float_format(_const_value)}")
			}
			
			file_text_close(_f);
			url_open(_filename)
			return [];
		},
	@"Generate full markdown-formatted documentation for all RunGML operators and view it in the browser.
	- args: [(filename='RunGML/manual.md')]
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
	
	new RunGML_Op("rec_start",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if _i.parent.recording {
					return new RunGML_Error("Console is already recording");
				}
				
				var _prog_type = "pass";
				if array_length(_l) > 0 _prog_type = _l[0]
				if !array_contains(["pass", "list", "last", "none"], _prog_type) {
					return new RunGML_Error($"Program type argument must be one of [pass, list, last, none], not {_l[0]}")	
				}
				if _prog_type == "none" {
					_i.parent.record = [];
				} else {
					_i.parent.record = [_prog_type]
				}
				_i.parent.recording = true;
			}
			return "Recording started";
		},
	@"If run from a console, start recording the following lines to be saved as a program whenever [rec_stop, program_name] is entered.
	- args: [(program_type)]
	- output: []",
		[new RunGML_Constraint_ArgType(0, "string", false)]
	)
	
	new RunGML_Op("rec_stop",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if not _i.parent.recording {
					return new RunGML_Error("Console is not recording, call rec_start first.");
				}
				
				if array_length(_l) < 1 {
					return new RunGML_Error("Must provide a program name");	
				}
				
				var _overwrite = false;
				if array_length(_l) > 1 {
					if _l[1] _overwrite = true;
				}
				var _path = $"RunGML/prog_recordings/{_l[0]}.json"
				if file_exists(_path) and not _overwrite {
					return new RunGML_Error($"A program with the name {_l[0]} already exists");
				}
				var _file = file_text_open_write(_path);
				var _json_string = json_stringify(_i.parent.record, true);
				file_text_write_string(_file, _json_string);
				file_text_close(_file);
				
				_i.parent.record = [];
				_i.parent.recording = false;
				_i.parent.skip_line_recording = true;
				return $"Saved program recording as: {_l[0]}";
			}
			return [];
		},
	@"If run from a console, stop recording and save recorded lines as a program.
	- args: [program_name]
	- output: []",
		[new RunGML_Constraint_ArgType(0, "string", true)]
	)
	
	new RunGML_Op("rec_cancel",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if not _i.parent.recording {
					return new RunGML_Error("Console is not recording, call rec_start first.");
				}
				
				_i.parent.record = [];
				_i.parent.recording = false;
				return "Recording cancelled"
			}
			return [];
		},
	@"If run from a console, cancel recording input lines.
	- args: []
	- output: []",
		[]
	)
	
	new RunGML_Op("rec_pause",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if not _i.parent.recording {
					return new RunGML_Error("Console is not recording, call rec_start or rec_resume first.");
				}
				_i.parent.recording = false;
				return "Recording paused"
			}
			return [];
		},
	@"If run from a console, pause recording input lines.  Resume recording later with rec_pause.
	- args: []
	- output: []",
		[]
	)
	
	new RunGML_Op("rec_resume",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if _i.parent.recording {
					return new RunGML_Error("Console is already recording.");
				}
				if array_length(_i.parent.record) < 1 {
					return new RunGML_Error("No recording to resume, call rec_start first");
				}
				_i.parent.recording = true;
				return "Recording resumed"
			}
			return [];
		},
	@"If run from a console, resume recording input lines, after pausing with rec_pause.
	- args: []
	- output: []",
		[]
	)
	
	new RunGML_Op("rec_preview",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				var _pretty = false;
				if array_length(_l) > 0 {
					if _l[0] _pretty = true;
				}
				return RunGML_Write(_i.parent.record, _pretty);
			}
			return [];
		},
	@"Preview the program currently stored as a recording, if one exists.  Accepts an optional argument which prints pretty JSON if true.
	- args: [(pretty)]
	- output: [preview]",
		[]
	)
	
	new RunGML_Op("rec_delete",
		function(_i, _l) {
			if object_get_name(variable_instance_get(_i.parent, "object_index")) == "oRunGML_Console" {
				_i.parent.skip_line_recording = true;
				if array_length(_l) < 1 {
					return new RunGML_Error("No line number specified for deletion");
				}
				var _index = _l[0];
				var _n_lines = 1;
				if array_length(_l) > 1 {
					_n_lines = _l[1];
				}
				
				var _max_lines = array_length(_i.parent.record)
				if _index + _n_lines > _max_lines {
					return new RunGML_Error($"Lines specified for deletion extend beyond length of recording ({_max_lines})");
				}
				
				array_delete(_i.parent.record, _index, _n_lines);
			}
			return [];
		},
	@"Delete one or more lines from the recorded program.
	- args: [start_line, (line_count=1)]
	- output: [preview]",
		[]
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

	0. Return the interpreter's entire alias struct
	1. If the argument names an operator or alias, return a list of all synonyms starting with the real name.
	2. Creates a new alias with nickname arg0 for operator arg1.  arg0 cannot be in use, arg1 must be defined.
	
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

	new RunGML_Op("pass",
		function(_i, _l=[]) {
			return [];
		},
	@"Do nothing
	- args: [*]
	- output: []"
	)
	
	new RunGML_Op("run",
		function(_i, _l) {
			if array_length(_l) == 1 {
				if is_struct(_l[0]) {
					if struct_exists(_l[0], "do") {
						_l = struct_get(_l[0], "do");
					}
				}
			}
			return _i.run(_l);
		},
	@"Run arguments as a program, with the first argument becoming the new operator.
	- args: [*]
	- output: *"
	)
	
	new RunGML_Op("run_clean",
		function(_i, _l) {
			var _new_i = new RunGML_Interpreter();
			if array_length(_l) == 1 {
				if is_struct(_l[0]) {
					if struct_exists(_l[0], "do") {
						_l = struct_get(_l[0], "do");
					}
				}
			}
			return _new_i.run(_l);
			delete _new_i;
		},
	@"Run arguments as a program, with the first argument becoming the new operator. Creates and uses a separate interpreter instance.
	- args: [*]
	- output: *"
	)
	
	new RunGML_Op("exec",
		function(_i, _l) {
			return _i.run(RunGML_Read(_l[0]));
		},
	@"Execute a string as a program.
	- args: [string]
	- output: *",
		[
			new RunGML_Constraint_ArgCount("eq", 1),
			new RunGML_Constraint_ArgType(0, "string")
		]
	)

	new RunGML_Op("do",
		function(_i, _l=[]) {
			if array_length(_l) < 2 _l[1] = [];
			return method_call(_l[0], _l[1]);
		},
	@"Execute a function with an optional list of arguments in its original context using method_call().
	- args: [function, ([args])]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "method"),
			new RunGML_Constraint_ArgType(1, "array", false)
		]
	)

	new RunGML_Op("do_here",
		function(_i, _l=[]) {
			if array_length(_l) < 2 _l[1] = [];
			return script_execute_ext(_l[0], _l[1]);
		},
	@"Execute a function with an optional list of arguments in the operator's context using script_execute_ext().  In most cases, use 'do' instead.
	- args: [function, ([args])]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "method"),
			new RunGML_Constraint_ArgType(1, "array", false)
		]
	)
	
	new RunGML_Op("last",
		function(_i, _l) {
			var _n = array_length(_l);
			if _n > 0 return _l[_n - 1];
			return [];
		},
	@"Return the value of the last argument
	- args: [*]
	- output: *"
	)
	
	new RunGML_Op("out",
		function(_i, _l) {
			return {"out": _l};
		},
	@"Wrap argument list in a struct so it can be returned unevaluated.
	- args: [*]
	- output: struct"
	)
	
	new RunGML_Op("in",
		function(_i, _l) {
			return struct_get(_l[0], "out");
		},
	@"Retrieve the output list from a struct produced by the 'out' operator.
	- args: [struct]
	- output: list",
		[new RunGML_Constraint_ArgType(0, "struct")]
	)
	
	new RunGML_Op("import",
		function(_i, _l) {
			if !file_exists(_l[0]) return [];
			var _file = file_text_open_read(_l[0]);
			var _json_string = "";
			while (!file_text_eof(_file)) {
				_json_string += file_text_read_string(_file);
				file_text_readln(_file);
			}
			file_text_close(_file);
			return RunGML_Read(_json_string);
		},
	@"Import JSON from a file
	- args: [filepath]
	- output: json",
		[new RunGML_Constraint_ArgType(0, "string")]
	)
	
	new RunGML_Op("runfile",
		function(_i, _l) {
			var _runner = "run_clean";
			if array_length(_l) > 1 {
				if not _l[1] _runner = "run";	
			}
			return _i.run([
				[_runner, ["import", _l[0]]]
			])
		},
	@"Run a program from a file
	- args: [filepath]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "string"),
			new RunGML_Constraint_ArgType(1, "bool", false)
		]
	)
	
	new RunGML_Op("runprog",
		function(_i, _l) {
			var _runner = "run_clean";
			if array_length(_l) > 1 {
				if not _l[1] _runner = "run";	
			}
			return _i.run([
				[_runner, ["import", ["string", "RunGML/programs/{0}.json", _l[0]]]]
			])
		},
	@"Run a program from a file in the incdlued RunGML/programs directory.
	- args: [program_name, (clean)]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "string"),
			new RunGML_Constraint_ArgType(1, "bool", false)
		]
	)
	
	new RunGML_Op("rec_replay",
		function(_i, _l) {
			var _runner = "run";
			if array_length(_l) > 1 {
				if _l[1] _runner = "run_clean";	
			}
			return _i.run([
				[_runner, ["import", ["string", "RunGML/prog_recordings/{0}.json", _l[0]]]]
			])
		},
	@"Run a program recorded via the console with rec_start/rec_stop
	- args: [program_name, (clean)]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "string"),
			new RunGML_Constraint_ArgType(1, "bool", false)
		]
	)
	
	new RunGML_Op("example",
		function(_i, _l) {
			var _runner = "run_clean";
			if array_length(_l) > 1 {
				if not _l[1] _runner = "run";	
			}
			return _i.run([_runner, ["import", ["string", "RunGML/programs/examples/{0}.json", _l[0]]]])
		},
	@"Run an included example program
	- args: [example_program_name]
	- output: *",
		[
			new RunGML_Constraint_ArgType(0, "string"),
			new RunGML_Constraint_ArgType(1, "bool", false)
		]
	)
	
	new RunGML_Op("export",
		function(_i, _l) {
			var _file = file_text_open_write(_l[0]);
			var _pretty = true;
			if array_length(_l) > 2 {
				_pretty = _l[2];	
			}
			var _json_string = RunGML_Write(_l[1], _pretty);
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
	
	new RunGML_Op("list",
		function(_i, _l=[]) {
			return variable_clone(_l);
		},
	@"Return arguments as a list
	- args: []
	- output: []"
	)
	
	new RunGML_Op("prog",
		function(_i, _l=[]) {
			var _n_args = array_length(_l);
			for (var _line=0; _line<_n_args; _line++) {
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
				} else if struct_exists(_l[1], "True") {
					_i.run(struct_get(_l[1], "True"));
				}
			} else if struct_exists(_l[1], "false") {
				_i.run(struct_get(_l[1], "false"));
			} else if struct_exists(_l[1], "False") {
				_i.run(struct_get(_l[1], "False"));	
			}
		},
	@"Evaluate and act on a conditional
	- args: [conditional, {'true': program, 'false': program}]
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

	new RunGML_Op("for",
		function(_i, _l) {
			//var _i=_l[0];
			if !struct_exists(_l[4], "do") return [];
		
			var _comparison = _l[1];
			var _reference = _l[2];
			var _increment = _l[3];
			var _program = struct_get(_l[4], "do");
		
			var _compare_func;
			switch _comparison {
				case "eq":
					_compare_func = function(_val, _ref) {return _val == _ref}
					break;
				case "neq":
					_compare_func = function(_val, _ref) {return _val != _ref}
					break;
				case "lt":
					_compare_func = function(_val, _ref) {return _val < _ref}
					break;
				case "gt":
					_compare_func = function(_val, _ref) {return _val > _ref}
					break;
				case "leq":
					_compare_func = function(_val, _ref) {return _val <= _ref}
					break;
				case "geq":
					_compare_func = function(_val, _ref) {return _val >= _ref}
					break;
				default:
					_compare_func = function(_val, _ref) {return false};
					break;
			}
		
			_i.loop_depth += 1;

			for (var i=_l[0]; _compare_func(i, _reference); i+=_increment){
				_i.loop_iter[_i.loop_depth] = i;
				_i.run(_program)
			
			}
		
			array_delete(_i.loop_iter, _i.loop_depth, 1)
			_i.loop_depth -= 1;
			return [];
		},
	@"Exectue a RunGML program in a for loop.  Comparison should be one of the following strings: 'eq', 'neq', 'gt', 'lt', 'geq', 'leq'
	        for (var i=[start]; i [comparison] [reference]; i += increment) {run(program)}
		
	- args: [start, comparison, reference, increment, {'do': program}]
	- output: []",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "string"),
			new RunGML_Constraint_ArgType(2, "numeric"),
			new RunGML_Constraint_ArgType(3, "numeric"),
			new RunGML_Constraint_ArgType(4, "struct")
		]
	)
	
	new RunGML_Op("while",
		function(_i, _l) {
			if !struct_exists(_l[0], "check") or !struct_exists(_l[0], "do") return [];
			var _check = struct_get(_l[0], "check")
			var _f = struct_get(_l[0], "do")
		
			_i.loop_depth += 1;
			_i.loop_iter[_i.loop_depth] = 0;
			while(true) {
				if _i.run(_check) {
					_i.loop_iter[_i.loop_depth] = _i.loop_iter[_i.loop_depth] + 1;
					_i.run(_f);
				} else break;
			}
			array_delete(_i.loop_iter, _i.loop_depth, 1)
			_i.loop_depth -= 1;
			return [];
		},
	@"Exectue a RunGML program while a condition is true
	- args: [{'check': program, 'do': program}]
	- output: []",
		[
			new RunGML_Constraint_ArgType(0, "struct")
		]
	)

	new RunGML_Op("repeat",
		function(_i, _l) {
			_i.loop_depth += 1;
			for (var i=0; i<_l[0]; i++) {
				_i.loop_iter[_i.loop_depth] = i;
				_i.run(struct_get(_l[1], "do"));
			}
			array_delete(_i.loop_iter, _i.loop_depth, 1)
			_i.loop_depth -= 1;
			return [];
		},
	@"Repeat a RunGML program a fixed number of times
	- args: [count, {'do': program}]
	- output: []",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "struct")
		]
	)

	new RunGML_Op("iter",
		function(_i, _l) {
			if _i.loop_depth >= 0 return _i.loop_iter[_i.loop_depth];
			else return undefined
		},
	@"Get the current loop iterator
	- args: []
	- output: []",
		[new RunGML_Constraint_ArgCount("eq", 0)]
	)

	new RunGML_Op("iters",
		function(_i, _l) {
			return _i.loop_iter
		},
	@"Get a list of all loop iterators
	- args: []
	- output: []",
		[new RunGML_Constraint_ArgCount("eq", 0)]
	)

	#endregion Control Flow
	
	#region Debugging

	new RunGML_Op ("print",
		function(_i, _l) {
			var _n_args = array_length(_l);
			for(var i=0; i<_n_args; i++) {
				show_debug_message(string(_l[i]));
			}
			return [];
		},
	@"Print a debug message
	    - args: [stringable, (...)]
	    - output: []"
	)

	new RunGML_Op ("debug",
		function(_i, _l) {
			var _enable = !is_debug_overlay_open();
			var _minimize = false;
			var _scale = 1.0
			var _alpha = 0.8
			var _n_args = array_length(_l);
			if _n_args > 0 {
				_enable = _l[0]
				if _n_args > 1 {
					_enable = _l[1]
					if _n_args > 2 {
						_enable = _l[2]
						if _n_args > 3 {
							_enable = _l[3]
						}
					}
				}
			}
			show_debug_overlay(_enable, _minimize, _scale, _alpha);
			return [];
		},
	@"Enable or disable the GameMaker deubg overlay. Passing zero arguments toggles its visibility.
	    - args: [(enable), (minimize), (scale), (alpha)]
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
			var _n_args = array_length(_l);
			for (var i=0; i<_n_args; i++) {
				_out += string(_l[i]);	
			}
			return _out;
		},
	@"Concatenate arguments into a single string
	    - args: [value, (...)]
	    - output: [string]",
	)

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

	0. Return the interpreter's entire registers struct.
	1. Return the value saved in the named register.
	2. Set the register named by the first argument to the value of the second argument.
	- args: [int] or [string]
	- output: *"
	)
	
	new RunGML_Op ("reference",
		function(_i, _l) {
			if array_length(_l) == 0 return _i.registers;
			if struct_exists(_i.ops, _l[0]) {
				var _n_args = array_length(_l)
				for (var i=1; i<_n_args; i++) {
					if struct_exists(_i.registers, _l[i]) {
						_l[i] = struct_get(_i.registers, _l[i]);
					}
				}
				return _i.run(_l);
			}
			else return undefined;
		},	
	@"Operate on referenced values.  Behavior depends on the number of arguments:

	0. Return the interpreter's registers struct (same as ['v'])
	1. (or more) If the first argument names an operator:
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
				var _n_args = array_length(_l);
				for (var i=1; i<_n_args; i++) {
					if variable_instance_exists(_i.parent, _l[i]) {
						_l[i] = variable_instance_get(_i.parent, _l[i]);
					}
				}
				return _i.run(_l);
			}
			else return undefined;
		},	
	@"Similar to the 'reference' ('r') operator, but substitutes with values from the parent's instance variables.  Behavior depends on the number of arguments:

	0. Return the names of all parent instance variables
	1. (or more) If the first argument names an operator:
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

	0. Return an empty struct
	1. Return {'struct': arg0}
	2. Return get_struct(arg0, arg1)
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

	2. Return variable_instance_get(arg0, arg1)
	3. Do variable_instance_set(arg0, arg1, arg2)
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

	0. Return an empty struct
	1. Return {'struct': arg0}
	2. Return get_struct(arg0, arg1)
	3. Return set_struct(arg0, arg1, arg2);
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
					if _l[1] >= array_length(_l[0]) return undefined;
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
	@"Create, read, or modify an array. Behavior depends on the number of arguments:

	0. Return an empty array
	1. Return [arg0]
	2. Return arg0[arg1]
	3. Set arg0[arg1] = arg2;
	- args: [(array), (index), (value)]
	- output: [*]"
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

	new RunGML_Op("asset",
		function(_i, _l) {
			return asset_get_index(_l[0])
		},
	@"Return the index of the named asset
	- args: [asset_name]
	- output: index",
		[new RunGML_Constraint_ArgType(0, "string")]
	)

	new RunGML_Op("type",
		function(_i, _l) {
			return typeof(_l[0])
		},
	@"Return the type of a variable
	- args: [*]
	- output: type_name",
		[new RunGML_Constraint_ArgCount("eq", 1)]
	)

	new RunGML_Op("asset_type",
		function(_i, _l) {
			return asset_get_type(_l[0])
		},
	@"Return the type of a variable
	- args: [*]
	- output: type_name",
		[new RunGML_Constraint_ArgType(0, ["ref", "string"])]
	)
	
	new RunGML_Op ("undefined",
		function(_i, _l) {
			if array_length(_l) > 0 return is_undefined(_l[0]);
			else return undefined;
		},
	@"Return the GameMaker constant undefined, or determines whether the optional argument is undefined.
	- args: [(variable)]
	- output: undefined or True/False",
		[new RunGML_Constraint_ArgCount("leq", 1)]
	)

	#endregion Accessors

	#region Math

	new RunGML_Op("add",
		function(_i, _l) {
			// a, b
			var _out = 0;
			var _n = array_length(_l)
			for (var i=0; i<_n; i++) {
				_out += _l[i];	
			}
			return _out;
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
			if array_length(_l) < 2 _l[1] = 1
		
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
			new RunGML_Constraint_ArgType(0, "alphanumeric"),
			new RunGML_Constraint_ArgType(1, "numeric", false)
		]
	)

	new RunGML_Op("dec",
		function(_i, _l) {
			if array_length(_l) < 2 _l[1] = 1
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
			new RunGML_Constraint_ArgType(0, "alphanumeric"),
			new RunGML_Constraint_ArgType(1, "numeric", false)
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

	new RunGML_Op("log",
		function(_i, _l) {
			if array_length(_l) == 1 {
				return log10(_l[0]);
			} else return logn(_l[1], _l[0]);
		},
	@"Compute a logarithm.  Behavior depends on the number of arguments:

	0. Return the log of the argument in base 10
	1. Return the log of arg0 in the base of arg1
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
	0. Return a value between 0 and 1 (inclusive)
	1. Return a value between 0 and arg0 (inclusive)
	2. Return a value between arg0 and arg1 (inclusive)
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
	0. Return either 0 or 1
	1. Return an integer between 0 and arg0 (inclusive)
	2. Return an integer between arg0 and arg1 (inclusive)
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

	#region Trigonometry
	new RunGML_Op("sin",
		function(_i, _l) {
			var _degrees = true;
			var _inverse = false;
			if array_length(_l) > 1 {
				_degrees = _l[1];
				if array_length(_l) > 2 _inverse = _l[2];
			}
		
			if _degrees {
				if _inverse return darcsin(_l[0]);
				else return dsin(_l[0])
			} else {
				if _inverse return arcsin(_l[0]);
				else return sin(_l[0])
			}
		},
	@"Return the sine of an angle in raidans.
	- args: [angle]
	- output: sin/dsin/arcsin/darcsin(angle)",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "bool", false),
			new RunGML_Constraint_ArgType(2, "bool", false)
		]
	)

	new RunGML_Op("cos",
		function(_i, _l) {
			var _degrees = true;
			var _inverse = false;
			if array_length(_l) > 1 {
				_degrees = _l[1];
				if array_length(_l) > 2 _inverse = _l[2];
			}
		
			if _degrees {
				if _inverse return darccos(_l[0]);
				else return dcos(_l[0])
			} else {
				if _inverse return arccos(_l[0]);
				else return cos(_l[0])
			}
		},
	@"Return the cosine of an angle in raidans.
	- args: [angle]
	- output: cos/dcos/arccos/darccos(angle)",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "bool", false),
			new RunGML_Constraint_ArgType(2, "bool", false)
		]
	)

	new RunGML_Op("tan",
		function(_i, _l) {
			var _degrees = true;
			var _inverse = false;
			if array_length(_l) > 1 {
				_degrees = _l[1];
				if array_length(_l) > 2 _inverse = _l[2];
			}
		
			if _degrees {
				if _inverse return darctan(_l[0]);
				else return dtan(_l[0])
			} else {
				if _inverse return arctan(_l[0]);
				else return tan(_l[0])
			}
		},
	@"Return the tangent of an angle in raidans.
	- args: [angle, (degrees=true), (inverse=false)]
	- output: tan/dtan/arctan/darctan(angle)",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "bool", false),
			new RunGML_Constraint_ArgType(2, "bool", false)
		]
	)

	new RunGML_Op("arctan2",
		function(_i, _l) {
			return arctan2(_l[0], _l[1]);
		},
	@"Return arctan2 of an angle y/x. y = opposite side of triangle and x = adjacent side of triangle
	- args: [y, x]
	- output: arctan2(y, x)",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "numeric")
		]
	)
	#endregion Trigonometry
	
	#region Objects

	new RunGML_Op("object",
		function(_i, _l) {
			var _inst;
			if is_string(_l[2]) {
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
			if is_string(_l[3]) {
				_l[3] = asset_get_index(_l[3])
			}
			if is_string(_l[2]) {
				return instance_create_layer(_l[0], _l[1], _l[2], _l[3]);
			} else {
				return instance_create_depth(_l[0], _l[1], _l[2], _l[3]);
			}
		},
	@"Create a new object instance
	- args: [x, y, depth/layer_name, object_name]
	- output: [instance_id]",
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
	- output: distance",
		[
			new RunGML_Constraint_ArgCount("eq", 4),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("point_dir",
		function(_i, _l) {
			return point_direction(_l[0], _l[1], _l[2], _l[3]);
		},
	@"Find the direction from one point to another
	- args: [x1, y1, x2, y2]
	- output: distance",
		[
			new RunGML_Constraint_ArgCount("eq", 4),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("lendir_x",
		function(_i, _l) {
			return lengthdir_x(_l[0], _l[1]);
		},
	@"Find the x component for a given vector
	- args: [length, direction]
	- output: x_component",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "numeric")
		]
	)

	new RunGML_Op("lendir_y",
		function(_i, _l) {
			return lengthdir_y(_l[0], _l[1]);
		},
	@"Find the y component for a given vector
	- args: [length, direction]
	- output: y_component",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "numeric")
		]
	)

	new RunGML_Op("angle",
		function(_i, _l) {
			return angle_difference(_l[0], _l[1]);
		},
	@"Find the shortest distance between two angles.
	- args: [end_angle, start_angle]
	- output: angle_difference",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "numeric")
		]
	)

	new RunGML_Op("dot",
		function(_i, _l) {
			return dot_product(_l[0], _l[1], _l[2], _l[3]);
		},
	@"Find the dot product of two 2d vectors
	- args: [x1, y1, x2, y2]
	- output: dot_product",
		[
			new RunGML_Constraint_ArgCount("eq", 4),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("dot3",
		function(_i, _l) {
			return dot_product_3d(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5]);
		},
	@"Find the dot product of two 3d vectors
	- args: [x1, y1, z1, x2, y2, z2]
	- output: dot_product",
		[
			new RunGML_Constraint_ArgCount("eq", 6),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("dot_norm",
		function(_i, _l) {
			return dot_product_normalised(_l[0], _l[1], _l[2], _l[3]);
		},
	@"Find the normalised dot product of two 2d vectors
	- args: [x1, y1, x2, y2]
	- output: dot_product",
		[
			new RunGML_Constraint_ArgCount("eq", 4),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("dot3_norm",
		function(_i, _l) {
			return dot_product_3d_normalised(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5]);
		},
	@"Find the normalised dot product of two 3d vectors
	- args: [x1, y1, z1, x2, y2, z2]
	- output: dot_product",
		[
			new RunGML_Constraint_ArgCount("eq", 6),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
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

	0. Return the name of the current room
	1. Go to the named room, if it exists
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

	new RunGML_Op("draw_self",
		function(_i, _l) {
			with(_l[0]) draw_self();
		},
	@"Draw text
	- args: [instance]
	- output: []",
		[
			new RunGML_Constraint_ArgType(0, "ref"),
		]
	)

	new RunGML_Op("sprite",
		function(_i, _l) {
			var _fname = _l[0]
			if !file_exists(_fname) return undefined;
			var _img_number = 1;
			var _remove_back = false;
			var _smoothing = false;
			var _x_origin = 0;
			var _y_origin = 0;
			var _n_args = array_length(_l);
			if _n_args > 1 {
				_img_number = _l[1]
				if _n_args > 2 {
					_remove_back = _l[2]
					if _n_args > 3 {
						_smoothing = _l[3]
						if _n_args > 4 {
							_x_origin = _l[4]
							if _n_args > 5 {
								_y_origin = _l[5]
							}
						}
					}
				}
			}
			return sprite_add(_fname, _img_number, _remove_back, _smoothing, _x_origin, _y_origin);
		},
	@"Create a new sprite from a file
	- args: [sprite_index, frame, x, y]
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
			if is_string(_l[0]) {
				_l[0] = asset_get_index(_l[0]);
			}
			draw_set_font(_l[0]);
			return [];
		},
	@"Get or set the draw font.
	- args: [(font name or asset reference)]
	- output: (font asset reference)",
		[new RunGML_Constraint_ArgType(0, ["string", "ref"])]
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
				if is_string(_font) {
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
	@"Get or set the draw font, horizontal alignment, vertical alignment, color, and alpha simultaneously.  Use to backup/restore settings before/after drawing to isolate changes.
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
			return irandom_range(0, 16777216);
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
	@"Return the RGB inverse of a color
	- args: [color]
	- output: color",
	)

	new RunGML_Op("color_inv_hue",
		function(_i, _l) {
			//return 16777216 - _l[0];
			var _h = color_get_hue(_l[0]);
			var _s = color_get_saturation(_l[0]);
			var _v = color_get_value(_l[0]);
			return make_color_hsv(255-_h, _s, _v);
		},
	@"Return the hue inverse of a color, with the same saturation and value
	- args: [color]
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
					if is_string(_sh) {
						_sh = asset_get_index(_sh);
					}
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

	new RunGML_Op("game_time",
		function(_i, _l) {
			return get_timer() / 1000000.0;
		},
	@"Return the time in seconds since the game began
	- args: []
	- output: number"
	)

	new RunGML_Op("current",
		function(_i, _l) {
			if array_length(_l) < 1 return date_current_datetime();
			switch(_l[0]) {
				case "s":
				case "sec":
				case "second":
					return current_second
				case "m":
				case "min":
				case "minute":
					return current_minute
				case "h":
				case "hr":
				case "hour":
					return current_hour
				case "d":
				case "day":
					return current_day
				case "w":
				case "wd":
				case "weekday":
					return current_weekday
				case "M":
				case "month":
					return current_month
				case "y":
				case "yr":
				case "year":
					return current_year
				case "t":
				case "time":
				default:
					return current_time
			}
		},
	@"Return the current time. Argument is a string specifying a date component: second/minute/hour/day/weekday/month/year, or s/m/h/d/w/M/y.  With no arguments, return the current datetime.
	- args: [('s'/'m'/'h'/'d'/'w'/'M'/'y')]
	- output: number",
		[new RunGML_Constraint_ArgType(0, "string" ,false)]
	)

	new RunGML_Op("datetime",
		function(_i, _l) {
			return date_create_datetime(_l[0], _l[1], _l[2], _l[3], _l[4], _l[5]);
		}, 
	@"Create a datetime value
	- args: [year, month, day, hour, minute, second]
	- output: datetime",
		[
			new RunGML_Constraint_ArgCount("eq", 6),
			new RunGML_Constraint_ArgType("all", "numeric")
		]
	)

	new RunGML_Op("datestring",
		function(_i, _l) {
			if array_length(_l) < 1 _l[0] = date_current_datetime();
			return date_datetime_string(_l[0]);
		}, 
	@"Create a string from a datetime value, or return the current datetime if no arguments are passed.
	- args: [(datetime)]
	- output: date_string",
		[
			new RunGML_Constraint_ArgType(0, "numeric", false)
		]
	)

	new RunGML_Op("date_get",
		function(_i, _l) {
			switch(_l[1]) {
				case "s":
				case "sec":
				case "second":
					return date_get_second(_l[0]);
				case "m":
				case "min":
				case "minute":
					return date_get_minute(_l[0]);
				case "h":
				case "hr":
				case "hour":
					return date_get_hour(_l[0]);
				case "d":
				case "day":
					return date_get_day(_l[0]);
				case "w":
				case "wd":
				case "weekday":
					return date_get_weekday(_l[0]);
				case "M":
				case "month":
					return date_get_month(_l[0]);
				case "y":
				case "yr":
				case "year":
					return date_get_year(_l[0]);
			}
		}, 
	@"Get the second, minute, hour, day, weekday, month, or year from a datetime value.
	- args: [datetime, 's'/'m'/'h'/'d'/'w'/'M'/'y']
	- output: number",
		[
			new RunGML_Constraint_ArgType(0, "numeric"),
			new RunGML_Constraint_ArgType(1, "string")
		]
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

	#region Cursor

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
				if is_string(_l[0]) {
					_obj = asset_get_index(_l[0]);
				}
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
			var _n_args = array_length(_l);
			if _n_args > 0 {
				_x = _l[0];
			} if _n_args > 1 {
				_y = _l[1];
			}
			if _n_args > 2 {
				if is_string(_l[2]) {
					_obj = asset_get_index(_l[0]);
				}
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

	#endregion Cursor

	#region Game
	new RunGML_Op("restart",
		function(_i, _l) {
			game_restart();
			return [];
		}, 
	@"Restart the game
	- args: []
	- output: []"
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
	#endregion Game

	#region Misc

	new RunGML_Op("rickroll",
		function(_i, _l) {
			url_open("https://sdlwdr.github.io/rickroll/rickroll.mp4");
			return [];
		},
	@"Got 'em!
	- args: []
	- output: []"
	)
	
	new RunGML_Op("screenshot",
		function(_i, _l) {
			if array_length(_l) > 0 {
				var _filename = _l[0]
			} else {
				var _date = date_current_datetime()
				var _filename = string(date_get_year(_date)) + "_" + 
								string(date_get_month(_date)) + "_" + 
								string(date_get_day(_date)) + "_" + 
								string(date_get_hour(_date)) + "_" + 
								string(date_get_minute(_date)) + "_" + 
								string(date_get_second(_date));
			}
			screen_save($"RunGML/screenshots/{_filename}.png");
			return [];
		},
	@"Save a screenshot to RunGML/screenshots/timestamp.png.  Or pass a filename in place of generating a timestamp.
	- args: [(filename)]
	- output: []"
	)
	#endregion Misc
}
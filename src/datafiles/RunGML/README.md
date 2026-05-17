# RunGML
A runtime scripting language for GameMaker.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Running Programs](#running-programs)
- [Syntax](#syntax)
    - [Loose JSON](#loose-json)
    - [List Evaluation Procedure](#list-evaluation-procedure)
    - [Single Line Programs](#single-line-programs)
    - [Multi Line Programs](#multi-line-programs)
    - [Variables](#variables)
    - [Register Operations](#register-operations)
- [Console](#console)
    - [Console Syntax Differences](#console-syntax-differences)
    - [Console-Specific Operators](#console-specific-operators)
    - [Console Keyboard Shortcuts](#console-keyboard-shortcuts)
- [Objects](#objects)
- [Operator Definitions](#operator-definitions)
    - [Constraint Definitions](#constraint-definitions)
- [Alias Definitions](#alias-definitons)
- [Acknowledgements](#acknowledgements)
- [Projects Using RunGML](#projects-using-rungml)

## Overview

RunGML is a runtime scripting language embedded in GameMaker Language.
It has a Lisp-like structure of nested lists, with a JSON-compatible syntax.
It is a replacement for GameMaker's obsoleted `execute_string` function, and then some.

You can use it to:
- Debug your code
- Provide modding support
- Add secret content from encrypted files
- Make arbitrary changes to your game while it runs.  Aything that can be done in GML can be done at runtime with RunGML.

In addition to the RunGML language definition and interpreter, this library also includes:
- An [interactive console](#console)
- A [template object](#objects) with events pre-defined to execute RunGML programs
- A test room, test object, and example programs to demonstrate basic functionality
    - See [bounce_annotated.md](bounce_annotated.md) for a line-by-line explanation of the [bounce](src/datafiles/RunGML/programs/examples/bounce.json) example program.
- Thorough documentation that can be accessed using `"help"` or `"manual`.  The latter generates markdown-formatted documentation for all operators (including any you define yourself), a copy of which is included here as [manual.md](manual.md).

## Installation

1. Download [RunGML.yymps](RunGML.yymps)
2. In GameMaker Studio, open the `Tools` menu and select `Import Local Package`.
3. Select the RunGML.ymmps file you just downloaded
4. Click `Add All` (or you can choose to skip anything/everything in the `Included Files` folder, unless you plan to run the test cases.)
5. Click `Import`
6. (Optional) Add an instance of the `oRunGML_Console` object to the first room of your program.

## Running Programs

First create an instance of the RunGML interpreter:

`RunGMLI = new RunGML_Interpreter()`

Then you can pass your program as a list:

`RunGMLI.run(["print", "Hello, world!"])`

You can also execute programs that are stored in JSON files:

`RunGMLI.runfile(["filepath"])`

Programs stored in `[included files directory]/RunGML/programs/` can be quickly run by name (excluding the `.json` extension, it will be added automatically):

`RunGMLI.runprog(["program_name"])`

You can also write and run code from within your game using the [console](#console).

## Syntax

Every program is a list.

The simplest program is: `[]`

The simplest operator (`"pass"`) is: `function(arg_list){return []}`

In addition to lists there are also strings, numbers, and structs.

### Loose JSON
As of v1.3.0 RunGML includes support for Loose JSON, via the [Extending JSON](https://github.com/JujuAdams/ExtendingJSON) library by Juju Adams.  This means that (with a few exceptions) you do not need to place quotation marks around operator names or strings.

See the [Extending JSON](https://github.com/JujuAdams/ExtendingJSON) documentation for details on the few cases where quotes are still required.

You can disable support for Loose JSON by setting `global.RunGML_importLooseJSON = false` in `scrRunGML_Config`.  You can cause JSON files to be *written* without quotes (e.g. by the `export` operator) by setting `global.RunGML_exportLooseJSON = true`, but that's not recommended.

Note that if read-support is enabled (`global.RunGML_importLooseJSON == true`), any quotes that *are* used must be double quotes.

See the [bounce_loose](src/datafiles/RunGML/programs/examples/bounce_loose.json) and [bounce](src/datafiles/RunGML/programs/examples/bounce.json) example programs to compare versions of the same code with and without the use of Loose JSON.

### List Evaluation Procedure

The RunGML Interpreter evaluates a list as follows:
- An empty list returns nothing.
- Any list elements that are lists will be evaluated first (recursively).
- If the first element is (or evaluates to) a string naming an operator:
    - That operator will be applied to any remaining elements and the result will be returned.
- Else if the first element names a built-in asset:
    - If that asset is callable, it will be called with the remaining elements as arguments and the result will be returned
    - Else that asset's index will be returned
- Else the first element itself will be returned as a string

In code:

```
run = function(_l) {
    if array_length(_l) < 1 return;
    for (var i=0; i<array_length(_l); i++) {
        if typeof(_l[i]) == "array" {
            _l[i] = run(_l[i]);
        }
    }
    var _op_name = array_shift(_l);
    var _out = _op_name;
    if struct_exists(language, _op_name) {
        var _op = struct_get(language, _op_name);
        var _out = _op.exec(self, _l);
    } else {
        var _asset = asset_get_index(_op_name)
        if _asset != -1 {
            if is_callable(_asset) {
                _out = struct_execute_ext(_asset, _l);
            else _out = _asset;
        }
    }
    return _out;
}
```

### Single-Line Programs

The basic syntax is:

`["operator_name", argument_0, argument_1, ...]`

For example, you can print a debug message with:

`["print", "Hello, world!"]`

Lists can be nested to create more complicated programs.  The following are all equivalent:

`["print", 5]`

`["print", ["add", 2, 3]]`

`["print", [["string", "{0}{1}{2}", "a", "d", "d"], 2, 3]]`


### Multi-Line Programs

In a sense every RunGML program is a single-line since it must be contained in a single outer list, but you can structure multi-line programs in several ways.

Common approaches are to start with the `"pass"`, `"last"`, or `"list"` operators.

`"pass"` evaluates all of its arguments and returns an empty list

`"last"` evaluates all of its arguments and returns the last one's value

`"list"` evaluates all of its arguments and returns a list of their values

### Variables

Each instance of the RunGML interpreter maintains a struct of named registers that can be used to define variables.
Setting and reading register values is done with the "v" (variable) operator
  - Passing a single argument will get the value stored in the register that argument names.
  - Passing two values will set the register named by the first argument to the value of the second argument.
  - Calling "v" with no arguments will return the register struct itself

Integers can also be used to name variables, but they will be cast to string representations before use.  For example, the following program will return the number 2:
```
["last",
  ["v", 0, 1]
  ["v", "0", 2]
  ["v", 0]
]
```

### Register Operations

The "r" (register) operator provides a convenient way to pass named variables to other operations.  Its first argument will be interpreted as a new operator name with any additional arguments passed to it, but any of those additional arguments that name a register with a defined value will pass that value to the new operator instead.

For example, the following programs are equivalent (they will all return the value 5):

```
["add", 2, 3]
```

```
["last",
  ["v", "foo", 2],
  ["v", "bar", 3],
  ["add", ["v", "foo"], ["v", "bar"]],
]
```

```
["last",
  ["v", "foo", 2],
  ["v", "bar", 3],
  ["r", "add", "foo", "bar"],
]
```

## Console

The console object (`oRunGML_Console`) provides a convenient way to debug and modify your game at runtime.

Console instances are persistent, but there can only be one instance at a time.  If you create a second it will destroy the first automatically.  Add one to your starting room and it will be usable throughout your game.

After creating an instance of oRunGML_Console, you can toggle it on and off by pressing `F9`.  This keybind can be changed by setting `global.RunGML_Console_toggleKey`, defined in `scrRunGML_Config`.

In RunGML code, the `"console"` operator facilitates interaction with the console instance, creating a new one first if needed.

When called with 0 arguments it returns the console instance's ID.  With one argument it gets an instance variable value, and with two arguments it sets a variable.

For example, the following two programs are equivalent ways of setting the console's text color to red:

```
['inst',  ['console'], 'text_color', ['rgb', 255, 0, 0]]
```

```
['console', 'text_color', ['rgb', 255, 0, 0]]
```

Note that the console gets its own instance of the RunGML interpreter.  When running RunGML code in the console, the `"parent"` operator is equivalent to the `"console"` operator.

### Console Syntax Differences

The console has some minor syntax conveniences that are not supported for programs stored in JSON files:
- It automatically adds a set of brackets around your command.
- It permits the use of single or double quotes, treating them identically (**except when building for HTML which requires double quotes, and when using Loose JSON which requires either no quotes or double quotes**).

So while a hello world program stored as JSON looks like: `["print", "Hello, world!"]`

The equivalent console command can look like: `'print", "Hello, World'`

Combining quote types in this way is not advised.  Consistent use of single quotes in the console is probably fine.  Future updates may change the way quotation marks and escape characters are handled to improve consistency.

With Loose JSON it would look like `print, "Hello, World"`.  Here, quotes are required around the text because it contains a commma.

Without the comma you can simply do `print, Hello World`

### Console-Specific Operators

- The `"clear"` operator will clear the console's history.
- The `"parent"` operator will return a reference to the console instance.
- The various `"rec_*"` operators can be used to record sequences of console inputs and replay them as programs.  This includes: `rec_start`, `rec_stop`, `rec_cancel`, `rec_pause`, `rec_resume`, `rec_preview`, `rec_line`, and `rec_delete`.  Consult the [manual](manual.md) for further details.  Note that these operators are non-functional when called from a non-console interpreter.

### Console Keyboard Shortcuts

The console supports the following bash-style keyboard shortcuts:
- **Up/Down Arrows**: Cycle through the command history
- **Control-L:** Clear the command history
- **Control-C:** Clear the current input string
- **Control-A:** Move the cursor to the start of the input string
- **Control-E:** Move the cursor to the end of the input string

## Objects

This library includes two template objects, `oRunGML_Object` and `oRunGML_ObjectTemplate`.
- `oRunGML_Object` provides only barebones functionality and is not directly useful.
- `oRunGML_ObjectTemplate` inherits from `oRunGML_Object` and sets up most events to execute RunGML programs passed through the event dictionary of the `"object"` operator.

You can create a new instance of `oRunGML_ObjectTemplate` with the "object" operator, which accepts the following arguments:
- x position
- y position
- layer name or depth (string or int)
- dictionary of {"event_name": [RunGML_program]}

Supported event names are: create, step_begin, step, step_end, pre_draw, draw_begin, draw, draw_end, post_draw, draw_gui_begin, draw_gui, draw_gui_end, destroy, clean_up, window_resize, game_start, game_end, room_start, room_end

The clock and bounce example programs showcase basic object creation.

## Operator Definitions

See the [manual](manual.md) for full documentation of supported operators and aliases.

Custom operators *should* be defined in the `RunGML_ConfigOps()` function in the [scrRunGML_Config](src/scripts/scrRunGML_Config/scrRunGML_Config.gml) script, which includes an example definition for `"test_operator`" that can be copied as a template.

Custom operators *can* be defined anywhere, anytime by calling:
```
new RunGML_Op("operator_name",
    function(_i, _l){},
    "documentation string",
    [
        constraint0,
        constraint1,
        ...
    ]
);
```

The function definition in the second argument must take two arguments: an instance of the RunGML interpreter, and a list of arguments being passed to the operator.  The function definition can also be replaced with a string, number, asset reference, etc. to define a constant.

Best practice is to format the documentation string as follows:
```
@"
Description of what the operator does.
- args: [list, of, expected, arguments]
- output: expected_output
"
```

### Constraint Definitions
The list of constraints is optional.  If present, it should contain `RunGML_Constraint_ArgCount`, and/or `RunGML_Constraint_ArgType` structs.  These can be used to enforce constraints on the number and type of arguments, respectively, that the operator will accept.  If violated, a `RunGML_Error` will be printed.

Note that constraint checking is a fairly intensive operation.  It is disabled by default, and can be enabled by setting the macro `RunGML_I_checkConstraints` to `true` in `scrRunGML_Config`.

#### RunGML_Constraint_ArgCount

Accpets two arguments:
1. _op: a string naming a comparison operator
2. _count: a number to compare against
    
Supported comparison operators and their functions are as follows:
- **"eq"**: arg_count == _count ?
- **"neq"**: arg_count != _count ?
- **"lt"**: arg_count < _count ?
- **"gt"**: arg_count > _count ?
- **"leq"**: arg_count <= _count ?
- **"geq"**: arg_count >= _count ?
- **"in"**: array_contains(_count) ?

Note that the "in" operator expects a list instead of integers instead of a single value.


#### RunGML_Constraint_ArgType

Accepts two required parameters:
1. An argument number (zero-indexed) or the string "all"
2. A string naming a type or list of types

And two optional parameters:
3. Whether the argument with the specified number is required. Defaults to False
4. Whether "bool" type requirements are strict.  Defaults to False, in which case arguments can be allowed as long as they can be cast to a bool.

In addition to the type names provided by GameMaker's `typeof()`, it also supports:
- "numeric" = ["number", "int32", "int64"]
- "alphanumeric" = ["string", "number", "int32", "int64"]

## Alias Definitons
Custom aliases can be added from anywhere using RunGML_alias("nickname", "operator_name").  They also *should* be defined in RunGML_ConfigOps().

It is possible to define an alias for anohter alias (ad infinitum) as well as for an operator.

## Acknowledgements
Thanks to:
- Juju Adams for the use of his [Extending JSON](https://github.com/JujuAdams/ExtendingJSON) library, and for assisting with performance improvement and other tidbits.
- TabularElf for the list of built-in constants used by [GMLspeak](https://github.com/tabularelf/GMLspeak), which is more or less copy-pasted into [scrRunGML_Constants](src/scripts/scrRunGML_Constants/scrRunGML_Constants.gml).
- Everyone else from the [GameMaker Kitchen](https://discord.gg/gamemakerkitchen) Discord server who has offered suggestions for improving this library (it's a wonderful community, go check it out).
- You, for using this library.  If you release a game (or some other project) that makes use of it, please let me know and I'll give you a mention below!

## Projects Using RunGML
- [Panomino](https://snail-dream.itch.io/panomino) (the game this library was originally created for)
- [Vertex Heaven](https://snail-dream.itch.io/vertex-heaven)

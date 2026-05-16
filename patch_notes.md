# RunGML Patch Notes

## 1.3.0 (2026-05-16)
#### Features
- Added operator definitions for nearly 700 previously inaccessible built-in constants.
    - Thanks to TabularElf for pointing me to the list of constants in [GMLspeak](https://github.com/tabularelf/GMLspeak), I would not have found them all on my own.
    - Non-LTS constants are still unsupported for now.  They'll probably be added whenever the new LTS gets released.
- Added `op_search` operator to display a list of all operator and alias names containing a given substring.
- Support for Loose JSON is now included and enabled by default for reading (writing still uses double-quotes by default)
    - Brought to you by the [ExtendingJSON](https://github.com/JujuAdams/ExtendingJSON) library, created by Juju Adams.
- Added a set of operators for recording sequences of console inputs, storing them as program files, and replaying the results.  Note that these operators are *only* functional when executed by an interpreter whose parent is a console instance.
    - Call `rec_start` to start recording.  By default, programs created this way will begin with `pass`, but you can call `rec_start, last` or `rec_start, list` to begin programs with those operators instead.  You can also call `rec_start, none` to use the next line input as the initial operator.
    - Call `rec_stop, program_name` to save all lines since calling `rec_start` to `[save_directory]/RunGML/prog_recordings/program_name.json`.
    - Call `rec_cancel` to stop recording without saving and discard all recorded lines.
    - Call `rec_pause` to temporarily pause recording.
    - Call `rec_resume` to resume recording after having called `rec_pause`.
    - Call `rec_replay, program_name` to run a program saved at `[save_directory]/RunGML/prog_recordings/program_name.json`
    - Call `rec_preview` to print any text that has been recorded so far, as a string.  Accepts an option arugment to print pretty JSON if true.
    - Call `rec_delete, index, count` to delete `count` lines from the recording, starting at line `index` (count is optional and defaults to 1).
- Added new `screenshot` operator.  Saves to `[save_dir]/RunGML/screenshots/current_timestamp.png` by default.  Accepts an optional arugment to specify a filename in place of the generated timestamp.
- The `if` operator now accepts capitalized versions of `True` and `False` as keys in the dictionary passed as its second argument.  These can be used without double quotes when LooseJSON is enabled, unlike `true` and `false` which must be double-quoted.

#### Bug Fixes & Code Safety
- Aliases can now be created for other aliases, and all layers of aliases will point to and be listed in the documentation for the original operator.
- Operators can now be defined for a specific instance of the RunGML interpreter, in cases it uses something other than the global set of definitions (this was already the case for aliases).
- Improved handling of attempts to redefine existing operators/aliases.  `scrRunGML_Config` now includes globals allowing/preventing overwriting of each definition type, and definition functions now accept an optional `_overwrite` argument which can supersede those globals.  For example, you cannot define a new operator using the name of an existing operator unless `RunGML_overwriteOps == true` or using the name of an existing alias unless `RunGML_overwriteAliases == true`; but, if you call `RunGML_Op()` with the argument `_overwrite=true`, that will allow you to bypass *both* of those global settings.
- Converted all macros in `scrRunGML_Config` to global variables with the same names, so they can be modified at runtime.
- Replaced all uses of `noone` with `undefined` (and all checks of `x == noone` with `is_undefined(x)`), aside from the definition of the `noone` constant.
- Made certain methods static to reduce memory consumption.

#### Organization & Documentation
- Moved definitions of operators, aliases, and constants into their own scripts, separate from the core RunGML functions.  These definitions are now wrapped in `RunGML_DefineOps`, `RunGML_DefineAliases`, and `RunGML_DefineConstants` functions to enable more precision about when and where their definitions are created.  All three of those, along with `RunGML_DefineConfig` will be called by `RunGML_Init`, which is run automatically the first time an instance of the `RunGML_Interpreter` is constructed.
- Documentation for constants now shows their value.
- Constant definitions are now listed in a separate section at the bottom of the manual.

#### Misc.
- The `run` operator no longer creates and uses a fresh instance of the interpreter, and will instead run from whichever instance calls it.
    - Added a new `run_clean` operator that preserves the old behavior.
    - The `example`, `runfile`, and `runprog` operators will all use `run_clean` by default, but now accept an optional second argument which will cause them to use `run` instead if that argument is false.
    - The `rec_replay` operator uses `run` by default, but accepts and optional second argument which will cause it to use `run_clean` instead if that argument is true.
- Removed `RunGML_opWrapper` and the `op` operator (obsoleted by v1.2.0).
- Removed redundant definitions for operators that behaved identically to built-in functions with the same names.
- The `op_list` and `op_names` operators now exclude constants by default, and support an optional argument that includes them if it's true
- Improved display of floats in console and documentation
    - Trailing zeroes are now trimmed by default.  Can be reverted by setting `global.RunGML_floatTrailingZeroes=true` in `scrRunGML_Config`
- Renamed `global.RunGML_Console_floatPrecision` to `global.RunGML_floatPrecision` since this setting now also applies to constants in the manual
- Enabled SDF for console font to improve legibility


## 1.2.0 (2026-02-18)
- If an initial list item is not recognized as a RunGML operator (or alias) it will now be interpreted as a built-in asset/function whenever possible, instead of the list simply returning that initial item as a string
    - This effectively removes the need for the `op` operator and RunGML_OpWrapper (which didn't work in a lot of cases anyways)
        - Those features still exist for now but may be removed at some point in the future and should be avoided
    - A defined RunGML operator (or alias) will take precendence over any built-ins with the same name
        - Future versions may remove or rename some operator definitions to allow built-in versions to be used normally (TBD)
    - This behavior can be disbaled by setting `global.RunGML_useBuiltinOps = false`
    - It's possible this is a terrible idea for some reason I haven't fully thought through, so keep enabled at your own risk and please report any weird behavior or disasterous consequences you encounter. Hopefully it's fine and useful.
- Removed the example RunGML_OpWrapper for `show_debug_message`
- Added a `bounce_loose` example program to demonstrate Loose JSON support
    - This will be run by the test object if `global.RunGML_importLooseJSON == true`
- Removed the extraneous `bounce_spr` example program
- The `add` operator now correctly sums an arbitrary number of arguments instead of just the first two

## 1.1.0 (2026-02-17)
- Added support for Loose JSON formatting
	- Requires manual addition of scripts from:
		https://github.com/JujuAdams/ExtendingJSON/tree/main/scripts
	- Can be enabled/disabled separately for read/write via new global variables in scrRunGML_Config
	- Hasn't been tested super thoroughly so let me know if you encounter any issues
	- Note that commas are still required, and if you use quotes with Loose JSON they MUST be double quotes
- The console no longer clears its input when toggled off
	- No more having to retype a long command after you accidentally hit the toggle key instead of enter
	- Old behavior can be restored by setting `clear_on_toggle=true` (but you can always just use `Ctl-L` to clear the input)

## 1.0.4 (2025-04-26)
- Fixed a bug that caused the console to record keystrokes while inactive
- Replaced `RunGML_Console_doPause` macro with user-definable `RunGML_Console_onToggle(_enabled)` function
- Added `RunGML_Console_canToggle` macro

## 1.0.3 (2025-04-16)
- Improved efficiency of memory allocation in the interpreter by making list execution non-destructive (Thank you @JujuAdams!)

## 1.0.2 (2025-04-13)
- Added a function to auto-generate operators for native GameMaker functions
    - Simply run: `RunGML_opWrapper("some_GameMaker_function_name")`
- Added a new operator: `"op"`
    - Provides an interface to `RunGML_opWrapper()`
- Added a new operator: `"iter"`
    - Returns the value of the current loop iterator
- Added a new operator: `"iters"`
    - Returns a list of loop iterator values ordered by increasing loop depth
- Added a new `loop` example program

## 1.0.1 (2025-04-13)

- Switched to semantic versioning (2025.04.11.0 -> 1.0.0)
- Added a macro to toggle constraint validation: `RunGML_I_checkConstraints`
- Changed some config settings from globals to macros
- The `"run"` operator now creates and uses a separate interperter instance
- Added a new operator: `"for"`
    - Takes 5 arguments:
        - starting value
        - name of comparison operator
        - reference value
        - increment value
        - program wrapped in a struct
    - Example usage: `["for", 0, "lt", 5, 1, {"do": ["print", "foo"]}]`
        - Will print the string "foo" five times
- Improved performance of `RunGML_clone()`
- Improved performance of type checking
- Improved performance when iterating over arrays
- Removed unnecessary debug message from bounce example program


## 2025.04.11.0

Initial release
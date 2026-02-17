# RunGML Patch Notes

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

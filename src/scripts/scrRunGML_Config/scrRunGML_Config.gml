// Configure settings and define additional operators here

// Perform constraint validation.  Show an error if an operator receives the wrong number or type of arguments.
// For debugging purposes, will negatively impact performance
#macro RunGML_I_checkConstraints false

// Set the key to toggle the console on/off
#macro RunGML_Console_toggleKey vk_f9

// Determine whether the console can be used
// For example, set to the value of a DEV_MODE macro to disable console access for players
#macro RunGML_Console_canToggle true

// Always recreate the console if it's destroyed (starts inactive -- press key defined above to activate)
#macro RunGML_Console_superPersistent true

// Allow new operator definitions to overwrite existing ones
#macro RunGML_overwriteOps true

// Enable debug output for interpreters
// Sets default behavior, can be changed for specific interpreter instances.
global.RunGML_I_debug = false;

// Set the number of decimal places to display for floating point numbers in the console
global.RunGML_Console_floatPrecision = 8;

// Set the console's font
global.RunGML_Console_font = fntRunGML_Console;

// Set the console's draw scale
global.RunGML_Console_scale = 1.0;

//Set lineheight for the console display
global.RunGML_Console_lineHeight = 18;
	
// Throw errors instead of just printing debug messages
// Sets default behavior, can be changed for specific interpreter instances
// The console interpreter will throw to its display regardless
global.RunGML_throwErrors = false;

// Support the use of Loose JSON formatting
// Requires manual addition of scripts from:
// https://github.com/JujuAdams/ExtendingJSON/tree/main/scripts
// For import: LooseJSONRead and LooseJSONBufferRead
// For export: LooseJSONWrite and LooseJSONBufferWrite
// Note: If you use quotes with LooseJSON, they must be double quotes, and commas are still required
global.RunGML_importLooseJSON = false;
global.RunGML_exportLooseJSON = false;

// Attempt to interpret the first argument of any list as a built-in asset/function
// Only applies if it's not recognized as a RunGML operator or alias first
global.RunGML_useBuiltinOps = true;

// Define custom behavior when toggling the console on/off
// For example: `global.paused = _enabled`
function RunGML_Console_OnToggle(_enabled) {
	
}

// Define your own operators, aliases, and colors inside this function
function RunGML_ConfigOps() {
	/*An operator definition has the following parameters:
		- A name
		- A constant, or a function that accepts an interpreter instance and list of arguments
		- An optional documentation string
		- An optional list of constraints
	*/
	new RunGML_Op("test_operator",
		function(_i, _l) {
			return "Hello, Config!"
		},
@"Test operator
- args: []
- output: string",
		[new RunGML_Constraint_ArgCount("geq", 0)]
	)

	// Operators can also define constants instead of functions
	new RunGML_Op("test_constant", 42);

	// You can also define aliases for operators
	RunGML_alias("test_alias", "test_operator")
	
	// And define new color names for use with the "color" operator
	RunGML_color("seafoam", #78aa9f)
}

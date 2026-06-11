function RunGML_DefineTest() {
	new RunGML_Op("test_operator",
		function(_i, _l) {
			return "Hello, Config!"
		},
		@"Test operator
- args: []
- output: string",
		[new RunGML_Constraint_ArgCount("geq", 0)]
	)

	// Operators can also define constant values
	new RunGML_Op("test_constant", 42);

	// You can also define aliases for operators
	RunGML_alias("test_alias", "test_operator");
	
	// Or even define aliases for other aliases, ad infinitum
	RunGML_alias("test_alias_alias", "test_alias");
	
	// And define new color names for use with the "color" operator
	RunGML_color("seafoam", #78aa9f)
	
	// If can create an accessor for an enum like this:
	enum RunGML_Test_Enum {
		foo,
		bar
	}
	
	new RunGML_Enum("RunGML_Test_Enum", {
		"foo": RunGML_Test_Enum.foo,
		"bar": RunGML_Test_Enum.bar
	})
	
	new RunGML_Enum("RunGML_Test_Enum2", {
		"foo": 0,
		"bar": 1
	})
}

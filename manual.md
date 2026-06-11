# RunGML Manual
			
## About

Version: 1.5.0

Homepage: https://github.com/sdelaughter/RunGML

## Table of Contents

- [Operator List](#operator-list)
- [Alias Definitions](#alias-definitions)
- [Operator Documentation](#operator-documentation)
- [Constant Definitions](#constant-definitions)


## Operator List
[AudioEffectType](#audioeffecttype), [AudioLFOType](#audiolfotype), [GM_is_sandboxed](#gm_is_sandboxed), [add](#add), [alias](#alias), [and](#and), [angle](#angle), [application_surface](#application_surface), [approach](#approach), [arctan2](#arctan2), [array](#array), [asset](#asset), [asset_type](#asset_type), [async_load](#async_load), [cat](#cat), [choose](#choose), [clear](#clear), [color](#color), [color_inv](#color_inv), [color_inv_hue](#color_inv_hue), [color_merge](#color_merge), [color_rand](#color_rand), [console](#console), [cos](#cos), [create](#create), [current](#current), [current_day](#current_day), [current_hour](#current_hour), [current_minute](#current_minute), [current_month](#current_month), [current_second](#current_second), [current_time](#current_time), [current_year](#current_year), [cursor](#cursor), [cursor_sprite](#cursor_sprite), [date_get](#date_get), [datestring](#datestring), [datetime](#datetime), [debug](#debug), [dec](#dec), [delta](#delta), [delta_time](#delta_time), [destroy](#destroy), [display_gui_h](#display_gui_h), [display_gui_w](#display_gui_w), [display_h](#display_h), [display_w](#display_w), [div](#div), [do](#do), [do_here](#do_here), [dot](#dot), [dot3](#dot3), [dot3_norm](#dot3_norm), [dot_norm](#dot_norm), [draw_alpha](#draw_alpha), [draw_circle](#draw_circle), [draw_color](#draw_color), [draw_ellipse](#draw_ellipse), [draw_font](#draw_font), [draw_format](#draw_format), [draw_halign](#draw_halign), [draw_line](#draw_line), [draw_point](#draw_point), [draw_rect](#draw_rect), [draw_self](#draw_self), [draw_valign](#draw_valign), [eq](#eq), [event_data](#event_data), [event_number](#event_number), [event_type](#event_type), [example](#example), [exec](#exec), [export](#export), [flexpanel_align](#flexpanel_align), [flexpanel_direction](#flexpanel_direction), [flexpanel_display](#flexpanel_display), [flexpanel_edge](#flexpanel_edge), [flexpanel_flex_direction](#flexpanel_flex_direction), [flexpanel_gutter](#flexpanel_gutter), [flexpanel_justify](#flexpanel_justify), [flexpanel_position_type](#flexpanel_position_type), [flexpanel_unit](#flexpanel_unit), [flexpanel_wrap](#flexpanel_wrap), [for](#for), [fps](#fps), [fps_real](#fps_real), [fullscreen](#fullscreen), [game_display_name](#game_display_name), [game_project_name](#game_project_name), [game_save_id](#game_save_id), [game_speed](#game_speed), [game_time](#game_time), [geq](#geq), [global](#global), [gm_manual](#gm_manual), [gt](#gt), [help](#help), [hsv](#hsv), [if](#if), [import](#import), [in](#in), [inc](#inc), [inst](#inst), [instance_count](#instance_count), [iter](#iter), [iters](#iters), [last](#last), [len](#len), [lendir_x](#lendir_x), [lendir_y](#lendir_y), [leq](#leq), [list](#list), [log](#log), [lt](#lt), [manual](#manual), [map_range](#map_range), [mod](#mod), [mouse_button](#mouse_button), [mouse_lastbutton](#mouse_lastbutton), [mouse_x](#mouse_x), [mouse_y](#mouse_y), [mult](#mult), [munge](#munge), [near](#near), [near_cursor](#near_cursor), [neq](#neq), [not](#not), [nth](#nth), [object](#object), [op_count](#op_count), [op_list](#op_list), [op_names](#op_names), [op_search](#op_search), [or](#or), [os_browser](#os_browser), [os_device](#os_device), [os_type](#os_type), [os_version](#os_version), [out](#out), [parent](#parent), [pass](#pass), [point_dir](#point_dir), [point_dist](#point_dist), [pow](#pow), [print](#print), [prog](#prog), [program_directory](#program_directory), [quit](#quit), [rand](#rand), [rand_int](#rand_int), [rand_seed](#rand_seed), [rec_cancel](#rec_cancel), [rec_delete](#rec_delete), [rec_line](#rec_line), [rec_pause](#rec_pause), [rec_preview](#rec_preview), [rec_replay](#rec_replay), [rec_resume](#rec_resume), [rec_start](#rec_start), [rec_stop](#rec_stop), [reference](#reference), [reference_parent](#reference_parent), [repeat](#repeat), [restart](#restart), [rgb](#rgb), [rickroll](#rickroll), [room](#room), [room_first](#room_first), [room_h](#room_h), [room_last](#room_last), [room_next](#room_next), [room_w](#room_w), [run](#run), [run_clean](#run_clean), [runfile](#runfile), [runprog](#runprog), [screenshot](#screenshot), [shader](#shader), [shader_reset](#shader_reset), [sin](#sin), [sprite](#sprite), [string](#string), [struct](#struct), [struct_keys](#struct_keys), [sub](#sub), [switch](#switch), [tan](#tan), [temp_directory](#temp_directory), [this](#this), [type](#type), [undefined](#undefined), [update](#update), [url_open](#url_open), [var](#var), [view_current](#view_current), [webgl_enabled](#webgl_enabled), [while](#while), [working_directory](#working_directory)

## Alias Definitions
- False -> false
- NaN -> nan
- True -> true
- a -> array
- divide -> div
- g -> global
- i -> inst
- l -> list
- multiply -> mult
- o -> object
- p -> parent
- q -> quit
- r -> reference
- rp -> reference_parent
- s -> struct
- str -> string
- subtract -> sub
- t -> this
- v -> var
- version -> RunGML_Version

## Operator Documentation

### AudioEffectType
Accessor for the AudioEffectType enum.
- members: [ "Bitcrusher","Delay","Gain","HPF2","LPF2","Reverb1","Tremolo","PeakEQ","HiShelf","LoShelf","EQ","Compressor" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### AudioLFOType
Accessor for the AudioLFOType enum.
- members: [ "InvSawtooth","Sawtooth","Sine","Square","Triangle" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### GM_is_sandboxed
[dynamic constant]

### add
Add two or more numbers (use 'cat' or 'string' to combine strings)
- args: [A, B]
- output: A + B (+ ...)
- constraints:
    - count(args) geq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### alias
Create an operator alias. Behavior depends on the number of arguments:

0. Return the interpreter's entire alias struct
1. If the argument names an operator or alias, return a list of all synonyms starting with the real name.
2. Creates a new alias with nickname arg0 for operator arg1.  arg0 cannot be in use, arg1 must be defined.
	
- args: [(nickname), (name)]
- output: struct or list
- constraints:
    - count(args) leq 2
    - typeof(args[0]) in [ "string" ] (optional)
    - typeof(args[1]) in [ "string" ] (optional)

### and
Logical and operator
- args: [A, B]
- output: A and B

### angle
Find the shortest distance between two angles.
- args: [end_angle, start_angle]
- output: angle_difference
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)

### application_surface
[dynamic constant]

### approach
Increment a number by some amount while staying within a range
- args: [number, increment, min, max]
- output: [number]
- constraints:
    - count(args) eq 4
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### arctan2
Return arctan2 of an angle y/x. y = opposite side of triangle and x = adjacent side of triangle
- args: [y, x]
- output: arctan2(y, x)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)

### array
Create, read, or modify an array. Behavior depends on the number of arguments:

0. Return an empty array
1. Return [arg0]
2. Return arg0[arg1]
3. Set arg0[arg1] = arg2

- args: [(array), (index), (value)]
- output: [*]
- aliases: [ "a" ]

### asset
Return the index of the named asset
- args: [asset_name]
- output: index
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### asset_type
Return the type of a variable
- args: [*]
- output: type_name
- constraints:
    - typeof(args[0]) in [ "ref","string" ] (required)

### async_load
[dynamic constant]

### cat
Concatenate arguments into a single string
- args: [value, (...)]
- output: [string]

### choose
Return a random element from a list.
- args: [(max=1)]
- output: number
- constraints:
    - typeof(args[0]) in [ "array" ] (required)

### clear
If run from a console, clear that console's history
- args: []
- output: instance
- constraints:
    - count(args) eq 0

### color
Create a color by name or hex code
- args: [string]
- output: color
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### color_inv
Return the RGB inverse of a color
- args: [color]
- output: color

### color_inv_hue
Return the hue inverse of a color, with the same saturation and value
- args: [color]
- output: color

### color_merge
Merge two colors by some amount
- args: [color1, color2, fraction]
- output: color3
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (required)

### color_rand
Create a random color
- args: []
- output: color

### console
Return a reference to the RunGML console, creating one if it doesn't exist
- args: []
- output: instance
- constraints:
    - count(args) leq 2
    - typeof(args[0]) in [ "string" ] (optional)

### cos
Return the cosine of an angle in raidans.
- args: [angle]
- output: cos/dcos/arccos/darccos(angle)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)
    - typeof(args[2]) in [ "bool" ] (optional)

### create
Create a new object instance
- args: [x, y, depth/layer_name, object_name]
- output: [instance_id]
- constraints:
    - count(args) eq 4
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "string","number","int32","int64" ] (required)
    - typeof(args[3]) in [ "string","number","int32","int64" ] (required)

### current
Return the current time. Argument is a string specifying a date component: second/minute/hour/day/weekday/month/year, or s/m/h/d/w/M/y.  With no arguments, return the current datetime.
- args: [('s'/'m'/'h'/'d'/'w'/'M'/'y')]
- output: number
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### current_day
[dynamic constant]

### current_hour
[dynamic constant]

### current_minute
[dynamic constant]

### current_month
[dynamic constant]

### current_second
[dynamic constant]

### current_time
[dynamic constant]

### current_year
[dynamic constant]

### cursor
Return the cursor's coordinates
- args: []
- output: [mouse_x, mouse_y]

### cursor_sprite
[dynamic constant]

### date_get
Get the second, minute, hour, day, weekday, month, or year from a datetime value.
- args: [datetime, 's'/'m'/'h'/'d'/'w'/'M'/'y']
- output: number
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "string" ] (required)

### datestring
Create a string from a datetime value, or return the current datetime if no arguments are passed.
- args: [(datetime)]
- output: date_string
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)

### datetime
Create a datetime value
- args: [year, month, day, hour, minute, second]
- output: datetime
- constraints:
    - count(args) eq 6
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### debug
Enable or disable the GameMaker deubg overlay. Passing zero arguments toggles its visibility.
- args: [(enable), (minimize), (scale), (alpha)]
- output: []

### dec
Decrement a variable by some amount.  If the variable is undefined, set it to that amount.
- args: [register_name, number]
- output: []
- constraints:
    - typeof(args[0]) in [ "string","number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (optional)

### delta
Return the time elapsed since the previous frame in seconds
- args: []
- output: number

### delta_time
[dynamic constant]

### destroy
Destroy an instance
- args: [instance_id]
- output: []

### display_gui_h
Returns the height of the display GUI.
- args: []
- output: [height]

### display_gui_w
Returns the width of the display GUI.
- args: []
- output: [width]

### display_h
Returns the height of the display.
- args: []
- output: [height]

### display_w
Returns the width of the display.
- args: []
- output: [width]

### div
Divide two numbers
- args: [A, B]
- output: A / B
- aliases: [ "divide" ]
- constraints:
    - count(args) eq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### do
Execute a function with an optional list of arguments in its original context using method_call().
- args: [function, ([args])]
- output: *
- constraints:
    - typeof(args[0]) in [ "method" ] (required)
    - typeof(args[1]) in [ "array" ] (optional)

### do_here
Execute a function with an optional list of arguments in the operator's context using script_execute_ext().  In most cases, use 'do' instead.
- args: [function, ([args])]
- output: *
- constraints:
    - typeof(args[0]) in [ "method" ] (required)
    - typeof(args[1]) in [ "array" ] (optional)

### dot
Find the dot product of two 2d vectors
- args: [x1, y1, x2, y2]
- output: dot_product
- constraints:
    - count(args) eq 4
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### dot3
Find the dot product of two 3d vectors
- args: [x1, y1, z1, x2, y2, z2]
- output: dot_product
- constraints:
    - count(args) eq 6
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### dot3_norm
Find the normalised dot product of two 3d vectors
- args: [x1, y1, z1, x2, y2, z2]
- output: dot_product
- constraints:
    - count(args) eq 6
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### dot_norm
Find the normalised dot product of two 2d vectors
- args: [x1, y1, x2, y2]
- output: dot_product
- constraints:
    - count(args) eq 4
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### draw_alpha
Get or set the draw alpha.
- args: [(alpha)]
- output: (alpha)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)

### draw_circle
Draw a circle
- args: [x, y, (r=1), (outline=false), (c_center=draw_color), (c_edge=draw_color)]
- output: []
- constraints:
    - count(args) in [ 3,4,5,6 ]
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (optional)
    - typeof(args[3]) in [ "bool" ] (optional)
    - typeof(args[4]) in [ "bool" ] (optional)

### draw_color
Get or set the draw color.
- args: [(color)]
- output: (color)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)

### draw_ellipse
Draw an ellipse
- args: [x1, y1, x2, y2, (outline=false), (c_center=draw_color), (c_edge=draw_color)]
- output: []
- constraints:
    - count(args) in [ 3,4,5,6 ]
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (required)
    - typeof(args[3]) in [ "number","int32","int64" ] (required)
    - typeof(args[4]) in [ "bool" ] (optional)
    - typeof(args[5]) in [ "number","int32","int64" ] (optional)
    - typeof(args[6]) in [ "number","int32","int64" ] (optional)

### draw_font
Get or set the draw font.
- args: [(font name or asset reference)]
- output: (font asset reference)
- constraints:
    - typeof(args[0]) in [ "string","ref" ] (required)

### draw_format
Get or set the draw font, horizontal alignment, vertical alignment, color, and alpha simultaneously.  Use to backup/restore settings before/after drawing to isolate changes.
- args: [([font, h_align, v_align, color, alpha])]
- output: ([font, h_align, v_align, color, alpha])
- constraints:
    - count(args) leq 1

### draw_halign
Get or set the horizontal draw alignment
- args: [(value)]
- output: (value)

### draw_line
Draw a line
- args: [x1, y1, x2, y2, (color), (color2)]
- output: []
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (required)
    - typeof(args[3]) in [ "number","int32","int64" ] (required)
    - typeof(args[4]) in [ "number","int32","int64" ] (optional)
    - typeof(args[5]) in [ "number","int32","int64" ] (optional)

### draw_point
Draw a point
- args: [x, y, (color)]
- output: []
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (optional)

### draw_rect
Draw a rectangle
- args: [x1, y1, x2, y2, (outline=false), (c1=draw_color), (c2=c1, c3=c1, c4=c1)]
- output: []
- constraints:
    - count(args) in [ 4,5,6,9 ]
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (required)
    - typeof(args[3]) in [ "number","int32","int64" ] (required)
    - typeof(args[4]) in [ "bool" ] (optional)
    - typeof(args[5]) in [ "number","int32","int64" ] (optional)
    - typeof(args[6]) in [ "number","int32","int64" ] (optional)
    - typeof(args[7]) in [ "number","int32","int64" ] (optional)
    - typeof(args[8]) in [ "number","int32","int64" ] (optional)

### draw_self
Draw text
- args: [instance]
- output: []
- constraints:
    - typeof(args[0]) in [ "ref" ] (required)

### draw_valign
Get or set the vertical draw alignment
- args: [(value)]
- output: (value)

### eq
Check whether two arguments are equivalent
- args: [A, B]
- output: [(A == B)]

### event_data
[dynamic constant]

### event_number
[dynamic constant]

### event_type
[dynamic constant]

### example
Run an included example program
- args: [example_program_name]
- output: *
- constraints:
    - typeof(args[0]) in [ "string" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)

### exec
Execute a string as a program.
- args: [string]
- output: *
- constraints:
    - count(args) eq 1
    - typeof(args[0]) in [ "string" ] (required)

### export
Export JSON to a file
- args: [path, data, (pretty=true)]
- output: []
- constraints:
    - typeof(args[0]) in [ "string" ] (required)
    - typeof(args[1]) in [ "array","struct" ] (required)
    - typeof(args[2]) in [ "bool" ] (optional)

### flexpanel_align
Accessor for the flexpanel_align enum.
- members: [ "auto","flex_start","center","flex_end","stretch","baseline","space_between","space_around","space_evenly" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_direction
Accessor for the flexpanel_direction enum.
- members: [ "inherit","LTR","RTL" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_display
Accessor for the flexpanel_display enum.
- members: [ "flex","none" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_edge
Accessor for the flexpanel_edge enum.
- members: [ "left","top","right","bottom","start","end","horizontal","vertical","all_edges" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_flex_direction
Accessor for the flexpanel_flex_direction enum.
- members: [ "column","column_reverse","row","row_reverse" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_gutter
Accessor for the flexpanel_gutter enum.
- members: [ "column","row","all_gutters" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_justify
Accessor for the flexpanel_justify enum.
- members: [ "start","center","flex_end","space_between","space_around","space_evenly" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_position_type
Accessor for the flexpanel_position_type enum.
- members: [ "relative","absolute" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_unit
Accessor for the flexpanel_unit enum.
- members: [ "point","percent","auto" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### flexpanel_wrap
Accessor for the flexpanel_wrap enum.
- members: [ "no_wrap","wrap","reverse" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### for
Exectue a RunGML program in a for loop.  Comparison should be one of the following strings: 'eq', 'neq', 'gt', 'lt', 'geq', 'leq'

	for (var i=[start]; i [comparison] [reference]; i += increment) {run(program)}
	
- args: [start, comparison, reference, increment, {'do': program}]
- output: []
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "string" ] (required)
    - typeof(args[2]) in [ "number","int32","int64" ] (required)
    - typeof(args[3]) in [ "number","int32","int64" ] (required)
    - typeof(args[4]) in [ "struct" ] (required)

### fps
Get the current fps (capped at the room speed)
- args: []
- output: fps

### fps_real
Get the current fps (not capped at the room speed)
- args: []
- output: fps_real

### fullscreen
Toggle fullscreen mode.  Set status with a single boolean argument, or swap status with no arguments.
- args: [(bool)]
- output: []

### game_display_name
[dynamic constant]

### game_project_name
[dynamic constant]

### game_save_id
[dynamic constant]

### game_speed
Get or set the game speed in terms of fps
- args: [(game_speed)]
- output: (game_speed)

### game_time
Return the time in seconds since the game began
	- args: []
	- output: number

### geq
Check whether the first argument is greater than or equal to the second
- args: [A, B]
- output: [(A >= B)]

### global
Create, read, or modify global variables. Behavior depends on the number of arguments:
0. Return an empty struct
1. Return {'struct': arg0}
2. Return get_struct(arg0, arg1)

- args: []
- output: []
- aliases: [ "g" ]

### gm_manual
Open the GameMaker manual website.
Opens to the homepage if no argument is passed.
Opens to the page corresponding to the search term if one exists.
Opens to a search for the search term if no page exists.

- args: [(search_term)]
- output: []

### gt
Check whether the first argument is greater than the second
- args: [A, B]
- output: [(A > B)]

### help
Display documentation for RunGML, or for an operator/alias named by the first argument.
If the first argument instead names a built-in asset, open its page on the GameMaker manual website.
- args: [(op_name)]
- output: doc_string
- constraints:
    - count(args) leq 1
    - typeof(args[0]) in [ "string" ] (optional)

### hsv
Create an HSV color
- args: [hue, saturation, value]
- output: color

### if
Evaluate and act on a conditional
- args: [conditional, {'true': program, 'false': program}]
- output: []
- constraints:
    - typeof(args[0]) in [ "bool" ] (required)
    - typeof(args[1]) in [ "struct" ] (required)

### import
Import JSON from a file
- args: [filepath]
- output: json
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### in
Retrieve the output list from a struct produced by the 'out' operator.
- args: [struct]
- output: list
- constraints:
    - typeof(args[0]) in [ "struct" ] (required)

### inc
Increment a variable by some amount.  If the variable is undefined, set it to that amount.
- args: [register_name, number]
- output: []
- constraints:
    - typeof(args[0]) in [ "string","number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (optional)

### inst
Get and set instance variables. Behavior depends on the number of arguments:

2. Return variable_instance_get(arg0, arg1)
3. Do variable_instance_set(arg0, arg1, arg2)

- args: [instance, index, (value)]
- output: *
- aliases: [ "i" ]

### instance_count
[dynamic constant]

### iter
Get the current loop iterator
- args: []
- output: []
- constraints:
    - count(args) eq 0

### iters
Get a list of all loop iterators
- args: []
- output: []
- constraints:
    - count(args) eq 0

### last
Return the value of the last argument
- args: [*]
- output: *

### len
Returns the length of a string, array, or struct.
- args: [string/array/struct]
- output: length

### lendir_x
Find the x component for a given vector
- args: [length, direction]
- output: x_component
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)

### lendir_y
Find the y component for a given vector
- args: [length, direction]
- output: y_component
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)

### leq
Check whether the first argument is less than or equal to the second
- args: [A, B]
- output: [(A <= B)]

### list
Return arguments as a list
- args: []
- output: []
- aliases: [ "l" ]

### log
Compute a logarithm.  Behavior depends on the number of arguments:

0. Return the log of the argument in base 10
1. Return the log of arg0 in the base of arg1

- args: [number, (base=10)]
- output: log_base(number)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (optional)

### lt
Check whether the first argument is less than the second
- args: [A, B]
- output: [(A < B)]

### manual
Generate full markdown-formatted documentation for all RunGML operators and view it in the browser.
- args: [(filename='RunGML/manual.md')]
- output: []
- constraints:
    - count(args) eq 0

### map_range
Map a value proportionally from one range to another
- args: [number, in_min, in_max, out_min, out_max]
- output: number
- constraints:
    - count(args) eq 5
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### mod
Modulo operator
- args: [A, B]
- output: A mod B
- constraints:
    - count(args) eq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### mouse_button
[dynamic constant]

### mouse_lastbutton
[dynamic constant]

### mouse_x
[dynamic constant]

### mouse_y
[dynamic constant]

### mult
Multiply two numbers
- args: [A, B]
- output: A * B
- aliases: [ "multiply" ]
- constraints:
    - count(args) eq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### munge
Modify a JSON object by evaluating any arrays or struct keys starting with a given prefix as RunGML programs.  Prefix defaults to global.RunGML_mungePrefix.
- args: [json, (interpreter), (prefix)]
- output: *
- constraints:
    - count(args) geq 1
    - count(args) leq 3

### near
Return index of instance (arg2) nearest to some coordinates (arg0, arg1).
- args: [(x=mouse_x), (y=mouse_y), (obj=any)]
- output: index
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)
    - typeof(args[0]) in [ "string","number","int32","int64" ] (optional)

### near_cursor
Return index of instance nearest to the mouse.  Optional argument specifies an object index or asset name.
- args: [(object_index/asset_name)]
- output: index
- constraints:
    - typeof(args[0]) in [ "string","number","int32","int64" ] (optional)

### neq
Check whether two arguments are not equal (inverse of 'eq')
- args: [A, B]
- output: [(A != B)]

### not
Return the inverse of the argument's boolean value
- args: [A]
- output: [!A]

### nth
Get the ordinal suffix for a given number
- args: [number]
- output: 'st', 'nd', 'rd', or 'th'

### object
Create a new oRunGML_Object instance and return its index
- args: [x, y, depth/layer_name, event_dictionary]
- output: oRunGML_Object instance
- aliases: [ "o" ]
- constraints:
    - count(args) eq 4
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "number","int32","int64" ] (required)
    - typeof(args[2]) in [ "string","number","int32","int64" ] (required)
    - typeof(args[3]) in [ "struct" ] (required)

### op_count
Return the number of supported operators
- args: []
- output: number
- constraints:
    - count(args) eq 0

### op_list
Return a list of supported operators
- args: [(include_constants=false)]
- output: [string, *]
- constraints:
    - typeof(args[0]) in [ "bool" ] (optional)

### op_names
Return a string listing names of supported operators
- args: [(include_constants)]
- output: string
- constraints:
    - typeof(args[0]) in [ "bool" ] (optional)

### op_search
Return a list of operators and aliases whose names contain a give string.
- args: [string]
- output: [string, *]
- constraints:
    - count(args) eq 1

### or
Logical or operator
- args: [A, B]
- output: [(A or B)]

### os_browser
[dynamic constant]

### os_device
[dynamic constant]

### os_type
[dynamic constant]

### os_version
[dynamic constant]

### out
Wrap argument list in a struct so it can be returned unevaluated.
- args: [*]
- output: struct

### parent
Return a reference to the RunGML interpreter's parent object.
- args: []
- output: instance
- aliases: [ "p" ]
- constraints:
    - count(args) leq 2

### pass
Do nothing
- args: [*]
- output: []

### point_dir
Find the direction from one point to another
- args: [x1, y1, x2, y2]
- output: distance
- constraints:
    - count(args) eq 4
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### point_dist
Find the distance between two points
- args: [x1, y1, x2, y2]
- output: distance
- constraints:
    - count(args) eq 4
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### pow
Raise one number to the power of another
- args: [A, B]
- output: A ^ B
- constraints:
    - count(args) eq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### print
Print a debug message
- args: [stringable, (...)]
- output: []

### prog
Run arguments as programs
- args: []
- output: []
- constraints:
    - typeof(args[0]) in [ "array" ] (required)

### program_directory
[dynamic constant]

### quit
Quit the game
- args: []
- output: []
- aliases: [ "q" ]

### rand
Return a random value.  Behavior depends on the number of arguments:
0. Return a value between 0 and 1 (inclusive)
1. Return a value between 0 and arg0 (inclusive)
2. Return a value between arg0 and arg1 (inclusive)

- args: [(max=1)]
- output: number
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)
    - typeof(args[1]) in [ "number","int32","int64" ] (optional)

### rand_int
Return a random integer.  Behavior depends on the number of arguments:
	
0. Return either 0 or 1
1. Return an integer between 0 and arg0 (inclusive)
2. Return an integer between arg0 and arg1 (inclusive)

- args: [(max=1)]
- output: number
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)
    - typeof(args[1]) in [ "number","int32","int64" ] (optional)

### rand_seed
Set the seed to the given value, or to a random value if no argument is provided.
- args: [(seed)]
- output: []
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (optional)

### rec_cancel
If run from a console, cancel recording input lines.
- args: []
- output: []

### rec_delete
Delete one or more lines from the recorded program.
- args: [start_line, (line_count=1)]
- output: [preview]

### rec_line
If no arguments are passed, return the number of lines that have been recorded.  If a number is passed, return the corresponding line (zero-indexed) from the recording as a string.
- args: [(line_number)]
- output: [count OR line]

### rec_pause
If run from a console, pause recording input lines.  Resume recording later with rec_pause.
- args: []
- output: []

### rec_preview
Preview the program currently stored as a recording, if one exists.  Accepts an optional argument which prints pretty JSON if true.
- args: [(pretty)]
- output: [preview]

### rec_replay
Run a program recorded via the console with rec_start/rec_stop
- args: [program_name, (clean)]
- output: *
- constraints:
    - typeof(args[0]) in [ "string" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)

### rec_resume
If run from a console, resume recording input lines, after pausing with rec_pause.
- args: []
- output: []

### rec_start
If run from a console, start recording the following lines to be saved as a program whenever [rec_stop, program_name] is entered.
- args: [(program_type)]
- output: []
- constraints:
    - typeof(args[0]) in [ "string" ] (optional)

### rec_stop
If run from a console, stop recording and save recorded lines as a program.
- args: [program_name]
- output: []
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### reference
Operate on referenced values.  Behavior depends on the number of arguments:

0. Return the interpreter's registers struct (same as ['v'])
1. (or more) If the first argument names an operator:
	- Substitute any other arguments that name defined reigsters with their values.
	- Run the first-argument operator on the resulting list of substituted arguments.
	- For example, the following two programs are functionally equivalent:
	    - ['r', 'add', 'foo', 'bar']
	    - ['add', ['v', 'foo'], ['v', 'bar']]
	- They will return the sum of the values in registers 'foo' and 'bar'.
	
- args: [(operator), (register_name, ...)]
- output: *
- aliases: [ "r" ]

### reference_parent
Similar to the 'reference' ('r') operator, but substitutes with values from the parent's instance variables.  Behavior depends on the number of arguments:

0. Return the names of all parent instance variables
1. (or more) If the first argument names an operator:
	- Substitute any other arguments that name parent instance variables with their values
	- Run the first-argument operator on the resulting list of substituted arguments.
	- For example, the following two programs are functionally equivalent:
	    - ['rp', 'add', 'foo', 'bar']
	    - ['add', ['p', 'foo'], ['p', 'bar']]
	- They will return the sum of the values in parent instance variables 'foo' and 'bar'.
	
- args: [(operator), (variable, ...)]
- output: *
- aliases: [ "rp" ]

### repeat
Repeat a RunGML program a fixed number of times
- args: [count, {'do': program}]
- output: []
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "struct" ] (required)

### restart
Restart the game
- args: []
- output: []

### rgb
Create an RGB color
- args: [red, green, blue]
- output: color

### rickroll
Got 'em!
- args: []
- output: []

### room
Behavior depends on the number of arguments:

0. Return the name of the current room
1. Go to the named room, if it exists

- args: [(room_name)]
- output: [(room_name)]

### room_first
[dynamic constant]

### room_h
Returns the height of the current room.
- args: []
- output: [height]

### room_last
[dynamic constant]

### room_next
Go to the next room.
- args: []
- output: [height]

### room_w
Returns the width of the current room.
- args: []
- output: [width]

### run
Run arguments as a program, with the first argument becoming the new operator.
- args: [*]
- output: *

### run_clean
Run arguments as a program, with the first argument becoming the new operator. Creates and uses a separate interpreter instance.
- args: [*]
- output: *

### runfile
Run a program from a file
- args: [filepath]
- output: *
- constraints:
    - typeof(args[0]) in [ "string" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)

### runprog
Run a program from a file in the incdlued RunGML/programs directory.
- args: [program_name, (clean)]
- output: *
- constraints:
    - typeof(args[0]) in [ "string" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)

### screenshot
Save a screenshot to RunGML/screenshots/timestamp.png.  Or pass a filename in place of generating a timestamp.
- args: [(filename)]
- output: []

### shader
Get or set the current shader. Zero arguments to get, one to set.
- args: [(shader)]
- output: [(shader)]
- constraints:
    - typeof(args[0]) in [ "string","number","int32","int64" ] (optional)

### shader_reset
Clear shaders
- args: []
- output: []

### sin
Return the sine of an angle in raidans.
- args: [angle]
- output: sin/dsin/arcsin/darcsin(angle)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)
    - typeof(args[2]) in [ "bool" ] (optional)

### sprite
Create a new sprite from a file
- args: [sprite_index, frame, x, y]
- output: []

### string
Format a string
- args: [template, (var0), ...]
- output: [string]
- aliases: [ "str" ]
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### struct
Create, read, or modify a struct. Behavior depends on the number of arguments:

0. Return an empty struct
1. Return {'struct': arg0}
2. Return struct_get(arg0, arg1)
3. Return struct_set(arg0, arg1, arg2)

- args: []
- output: []
- aliases: [ "s" ]

### struct_keys
Get a list of the keys in a struct
- args: [struct]
- output: [string, ...]

### sub
Subtract two numbers
- args: [A, B]
- output: A - B
- aliases: [ "subtract" ]
- constraints:
    - count(args) eq 2
    - typeof(args[all]) in [ "number","int32","int64" ] (required)

### switch
Perform switch/case evaluation
- args: [value, {'case0': program, 'case1': program, 'default': program}]
- output: []
- constraints:
    - count(args) eq 2
    - typeof(args[1]) in [ "struct" ] (required)

### tan
Return the tangent of an angle in raidans.
- args: [angle, (degrees=true), (inverse=false)]
- output: tan/dtan/arctan/darctan(angle)
- constraints:
    - typeof(args[0]) in [ "number","int32","int64" ] (required)
    - typeof(args[1]) in [ "bool" ] (optional)
    - typeof(args[2]) in [ "bool" ] (optional)

### temp_directory
[dynamic constant]

### this
Return a reference to the current RunGML interpreter
- args: []
- output: instance
- aliases: [ "t" ]
- constraints:
    - count(args) eq 0

### type
Return the type of a variable
- args: [*]
- output: type_name
- constraints:
    - count(args) eq 1

### undefined
Return the GameMaker constant undefined, or determines whether the optional argument is undefined.
- args: [(variable)]
- output: undefined or True/False
- constraints:
    - count(args) leq 1

### update
Open the RunGML homepage in the browser
- args: []
- output: string
- constraints:
    - count(args) eq 0

### url_open
Open a URL in the default browser
- args: [URL]
- output: []
- constraints:
    - typeof(args[0]) in [ "string" ] (required)

### var
Get and set variables.  Behavior changes based on number of arguments:

0. Return the interpreter's entire registers struct.
1. Return the value saved in the named register.
2. Set the register named by the first argument to the value of the second argument.

- args: [int] or [string]
- output: *
- aliases: [ "v" ]

### view_current
[dynamic constant]

### webgl_enabled
[dynamic constant]

### while
Exectue a RunGML program while a condition is true
- args: [{'check': program, 'do': program}]
- output: []
- constraints:
    - typeof(args[0]) in [ "struct" ] (required)

### working_directory
[dynamic constant]


## Constant Definitions

- GM_Version = 1.5.0.0
- GM_build_date = 46183.43852703
- GM_build_type = run
- GM_runtime_version = 2026.0.0.23
- RunGML_Version = 1.5.0
- all = -3
- animcurvetype_catmullrom = 1
- animcurvetype_linear = 0
- asset_animationcurve = 10
- asset_font = 6
- asset_object = 0
- asset_particlesystem = 11
- asset_path = 4
- asset_room = 3
- asset_script = 5
- asset_sequence = 9
- asset_shader = 8
- asset_sound = 2
- asset_sprite = 1
- asset_tiles = 13
- asset_timeline = 7
- asset_unknown = -1
- audio_3d = 2
- audio_bus_main = { bypass : 0, gain : 1, effects : [ undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined ] }
- audio_falloff_exponent_distance = 5
- audio_falloff_exponent_distance_clamped = 6
- audio_falloff_exponent_distance_scaled = 8
- audio_falloff_inverse_distance = 1
- audio_falloff_inverse_distance_clamped = 2
- audio_falloff_linear_distance = 3
- audio_falloff_linear_distance_clamped = 4
- audio_falloff_none = 0
- audio_mono = 0
- audio_stereo = 1
- bboxkind_diamond = 3
- bboxkind_ellipse = 2
- bboxkind_precise = 0
- bboxkind_rectangular = 1
- bboxmode_automatic = 0
- bboxmode_fullimage = 1
- bboxmode_manual = 2
- bm_add = 1
- bm_dest_alpha = 7
- bm_dest_color = 9
- bm_dest_colour = 9
- bm_eq_add = 1
- bm_eq_max = 2
- bm_eq_min = 4
- bm_eq_reverse_subtract = 5
- bm_eq_subtract = 3
- bm_inv_dest_alpha = 8
- bm_inv_dest_color = 10
- bm_inv_src_alpha = 6
- bm_inv_src_color = 4
- bm_inv_src_colour = 4
- bm_max = 2
- bm_normal = 0
- bm_one = 2
- bm_src_alpha = 5
- bm_src_alpha_sat = 11
- bm_src_color = 3
- bm_src_colour = 3
- bm_subtract = 3
- bm_zero = 1
- browser_chrome = 3
- browser_edge = 11
- browser_firefox = 2
- browser_ie = 1
- browser_ie_mobile = 10
- browser_not_a_browser = -1
- browser_opera = 6
- browser_safari = 4
- browser_safari_mobile = 5
- browser_tizen = 9
- browser_unknown = 0
- browser_windows_store = 8
- buffer_bool = 10
- buffer_f16 = 7
- buffer_f32 = 8
- buffer_f64 = 9
- buffer_fast = 3
- buffer_fixed = 0
- buffer_grow = 1
- buffer_s16 = 4
- buffer_s32 = 6
- buffer_s8 = 2
- buffer_seek_end = 2
- buffer_seek_relative = 1
- buffer_seek_start = 0
- buffer_string = 11
- buffer_text = 13
- buffer_u16 = 3
- buffer_u32 = 5
- buffer_u64 = 12
- buffer_u8 = 1
- buffer_vbuffer = 4
- buffer_wrap = 2
- c_aqua = 16776960
- c_black = 0
- c_blue = 16711680
- c_dkgray = 4210752
- c_fuchsia = 16711935
- c_gray = 8421504
- c_green = 32768
- c_lime = 65280
- c_ltgray = 12632256
- c_maroon = 128
- c_navy = 8388608
- c_olive = 32896
- c_orange = 4235519
- c_purple = 8388736
- c_red = 255
- c_silver = 12632256
- c_teal = 8421376
- c_white = 16777215
- c_yellow = 65535
- cmpfunc_always = 8
- cmpfunc_equal = 3
- cmpfunc_greater = 5
- cmpfunc_greaterequal = 7
- cmpfunc_less = 2
- cmpfunc_lessequal = 4
- cmpfunc_never = 1
- cmpfunc_notequal = 6
- cr_appstart = -19
- cr_arrow = -2
- cr_beam = -4
- cr_cross = -3
- cr_default = 0
- cr_drag = -12
- cr_handpoint = -21
- cr_hourglass = -11
- cr_none = -1
- cr_size_all = -22
- cr_size_nesw = -6
- cr_size_ns = -7
- cr_size_nwse = -8
- cr_size_we = -9
- cr_uparrow = -10
- cull_clockwise = 1
- cull_counterclockwise = 2
- cull_noculling = 0
- device_emulator = 256
- device_ios_ipad = 2
- device_ios_ipad_retina = 3
- device_ios_iphone = 0
- device_ios_iphone5 = 4
- device_ios_iphone6 = 5
- device_ios_iphone6plus = 6
- device_ios_iphone_retina = 1
- device_ios_unknown = -1
- device_tablet = 2
- display_landscape = 0
- display_landscape_flipped = 2
- display_portrait = 1
- display_portrait_flipped = 3
- dll_cdecl = 0
- dll_stdcall = 1
- ds_type_grid = 5
- ds_type_list = 2
- ds_type_map = 1
- ds_type_priority = 6
- ds_type_queue = 4
- ds_type_stack = 3
- e = 2.71828183
- ef_cloud = 9
- ef_ellipse = 2
- ef_explosion = 0
- ef_firework = 3
- ef_flare = 8
- ef_rain = 10
- ef_ring = 1
- ef_smoke = 4
- ef_smokeup = 5
- ef_snow = 11
- ef_spark = 7
- ef_star = 6
- ev_alarm = 2
- ev_animation_end = 7
- ev_async_audio_playback = 74
- ev_async_audio_recording = 73
- ev_async_dialog = 63
- ev_async_push_notification = 71
- ev_async_save_load = 72
- ev_async_social = 70
- ev_async_system_event = 75
- ev_async_web = 62
- ev_async_web_cloud = 67
- ev_async_web_iap = 66
- ev_async_web_image_load = 60
- ev_async_web_networking = 68
- ev_async_web_steam = 69
- ev_boundary = 1
- ev_boundary_view0 = 50
- ev_boundary_view1 = 51
- ev_boundary_view2 = 52
- ev_boundary_view3 = 53
- ev_boundary_view4 = 54
- ev_boundary_view5 = 55
- ev_boundary_view6 = 56
- ev_boundary_view7 = 57
- ev_broadcast_message = 76
- ev_cleanup = 12
- ev_collision = 4
- ev_create = 0
- ev_destroy = 1
- ev_draw = 8
- ev_draw_begin = 72
- ev_draw_end = 73
- ev_draw_normal = 0
- ev_draw_post = 77
- ev_draw_pre = 76
- ev_end_of_path = 8
- ev_game_end = 3
- ev_game_start = 2
- ev_gesture = 13
- ev_gesture_double_tap = 1
- ev_gesture_drag_end = 4
- ev_gesture_drag_start = 2
- ev_gesture_dragging = 3
- ev_gesture_flick = 5
- ev_gesture_pinch_end = 9
- ev_gesture_pinch_in = 7
- ev_gesture_pinch_out = 8
- ev_gesture_pinch_start = 6
- ev_gesture_rotate_end = 12
- ev_gesture_rotate_start = 10
- ev_gesture_rotating = 11
- ev_gesture_tap = 0
- ev_global_gesture_double_tap = 65
- ev_global_gesture_drag_end = 68
- ev_global_gesture_drag_start = 66
- ev_global_gesture_dragging = 67
- ev_global_gesture_flick = 69
- ev_global_gesture_pinch_end = 73
- ev_global_gesture_pinch_in = 71
- ev_global_gesture_pinch_out = 72
- ev_global_gesture_pinch_start = 70
- ev_global_gesture_rotate_end = 76
- ev_global_gesture_rotate_start = 74
- ev_global_gesture_rotating = 75
- ev_global_gesture_tap = 64
- ev_global_left_button = 50
- ev_global_left_press = 53
- ev_global_left_release = 56
- ev_global_middle_button = 52
- ev_global_middle_press = 55
- ev_global_middle_release = 58
- ev_global_right_button = 51
- ev_global_right_press = 54
- ev_global_right_release = 57
- ev_gui = 64
- ev_gui_begin = 74
- ev_gui_end = 75
- ev_keyboard = 5
- ev_keypress = 9
- ev_keyrelease = 10
- ev_left_button = 0
- ev_left_press = 4
- ev_left_release = 7
- ev_middle_button = 2
- ev_middle_press = 6
- ev_middle_release = 9
- ev_mouse = 6
- ev_mouse_enter = 10
- ev_mouse_leave = 11
- ev_mouse_wheel_down = 61
- ev_mouse_wheel_up = 60
- ev_no_button = 3
- ev_no_more_health = 9
- ev_no_more_lives = 6
- ev_other = 7
- ev_outside = 0
- ev_outside_view0 = 40
- ev_outside_view1 = 41
- ev_outside_view2 = 42
- ev_outside_view3 = 43
- ev_outside_view4 = 44
- ev_outside_view5 = 45
- ev_outside_view6 = 46
- ev_outside_view7 = 47
- ev_pre_create = 14
- ev_right_button = 1
- ev_right_press = 5
- ev_right_release = 8
- ev_room_end = 5
- ev_room_start = 4
- ev_step = 3
- ev_step_begin = 1
- ev_step_end = 2
- ev_step_normal = 0
- ev_user0 = 10
- ev_user1 = 11
- ev_user10 = 20
- ev_user11 = 21
- ev_user12 = 22
- ev_user13 = 23
- ev_user14 = 24
- ev_user15 = 25
- ev_user2 = 12
- ev_user3 = 13
- ev_user4 = 14
- ev_user5 = 15
- ev_user6 = 16
- ev_user7 = 17
- ev_user8 = 18
- ev_user9 = 19
- fa_archive = 32
- fa_bottom = 2
- fa_center = 1
- fa_directory = 16
- fa_hidden = 2
- fa_left = 0
- fa_middle = 1
- fa_readonly = 1
- fa_right = 2
- fa_sysfile = 4
- fa_top = 0
- fa_volumeid = 8
- false = 0
- gamespeed_fps = 0
- gamespeed_microseconds = 1
- gp_axis_acceleration_x = 32789
- gp_axis_acceleration_y = 32790
- gp_axis_acceleration_z = 32791
- gp_axis_angular_velocity_x = 32792
- gp_axis_angular_velocity_y = 32793
- gp_axis_angular_velocity_z = 32794
- gp_axis_orientation_w = 32798
- gp_axis_orientation_x = 32795
- gp_axis_orientation_y = 32796
- gp_axis_orientation_z = 32797
- gp_axislh = 32785
- gp_axislv = 32786
- gp_axisrh = 32787
- gp_axisrv = 32788
- gp_extra1 = 32800
- gp_extra2 = 32801
- gp_extra3 = 32802
- gp_extra4 = 32803
- gp_extra5 = 32809
- gp_extra6 = 32810
- gp_face1 = 32769
- gp_face2 = 32770
- gp_face3 = 32771
- gp_face4 = 32772
- gp_home = 32799
- gp_padd = 32782
- gp_paddlel = 32805
- gp_paddlelb = 32807
- gp_paddler = 32804
- gp_paddlerb = 32806
- gp_padl = 32783
- gp_padr = 32784
- gp_padu = 32781
- gp_select = 32777
- gp_shoulderl = 32773
- gp_shoulderlb = 32775
- gp_shoulderr = 32774
- gp_shoulderrb = 32776
- gp_start = 32778
- gp_stickl = 32779
- gp_stickr = 32780
- gp_touchpadbutton = 32808
- infinity = inf
- kbv_autocapitalize_characters = 3
- kbv_autocapitalize_none = 0
- kbv_autocapitalize_sentences = 2
- kbv_autocapitalize_words = 1
- kbv_returnkey_continue = 10
- kbv_returnkey_default = 0
- kbv_returnkey_done = 9
- kbv_returnkey_emergency = 11
- kbv_returnkey_go = 1
- kbv_returnkey_google = 2
- kbv_returnkey_join = 3
- kbv_returnkey_next = 4
- kbv_returnkey_route = 5
- kbv_returnkey_search = 6
- kbv_returnkey_send = 7
- kbv_returnkey_yahoo = 8
- kbv_type_ascii = 1
- kbv_type_default = 0
- kbv_type_email = 3
- kbv_type_numbers = 4
- kbv_type_phone = 5
- kbv_type_phone_name = 6
- kbv_type_url = 2
- layerelementtype_background = 1
- layerelementtype_instance = 2
- layerelementtype_oldtilemap = 3
- layerelementtype_particlesystem = 6
- layerelementtype_sequence = 8
- layerelementtype_sprite = 4
- layerelementtype_tile = 7
- layerelementtype_tilemap = 5
- layerelementtype_undefined = 0
- lighttype_dir = 0
- lighttype_point = 1
- matrix_projection = 1
- matrix_view = 0
- matrix_world = 2
- mb_any = -1
- mb_left = 1
- mb_middle = 3
- mb_none = 0
- mb_right = 2
- mb_side1 = 4
- mb_side2 = 5
- mip_markedonly = 2
- mip_off = 0
- mip_on = 1
- nan = NaN
- network_config_avoid_time_wait = 4
- network_config_connect_timeout = 0
- network_config_disable_reliable_udp = 3
- network_config_enable_reliable_udp = 2
- network_config_use_non_blocking_socket = 1
- network_config_websocket_protocol = 5
- network_connect_blocking = 1
- network_connect_nonblocking = 2
- network_connect_none = 0
- network_send_binary = 1
- network_send_text = 2
- network_socket_bluetooth = 2
- network_socket_tcp = 0
- network_socket_udp = 1
- network_socket_ws = 6
- network_type_connect = 1
- network_type_data = 3
- network_type_disconnect = 2
- network_type_down = 7
- network_type_non_blocking_connect = 4
- network_type_up = 5
- network_type_up_failed = 6
- nineslice_blank = 3
- nineslice_bottom = 3
- nineslice_center = 4
- nineslice_centre = 4
- nineslice_hide = 4
- nineslice_left = 0
- nineslice_mirror = 2
- nineslice_repeat = 1
- nineslice_right = 2
- nineslice_stretch = 0
- nineslice_top = 1
- noone = -4
- os_android = 4
- os_gdk = 23
- os_gxgames = 24
- os_ios = 3
- os_linux = 6
- os_macosx = 1
- os_operagx = 24
- os_permission_denied = 0
- os_permission_denied_dont_request = -1
- os_permission_granted = 1
- os_ps4 = 14
- os_ps5 = 22
- os_switch = 21
- os_tvos = 20
- os_unknown = -1
- os_windows = 0
- os_xboxseriesxs = 23
- path_action_continue = 2
- path_action_restart = 1
- path_action_reverse = 3
- path_action_stop = 0
- phi = 1.61803399
- phy_debug_render_aabb = 8
- phy_debug_render_collision_pairs = 64
- phy_debug_render_coms = 4
- phy_debug_render_core_shapes = 32
- phy_debug_render_joints = 2
- phy_debug_render_obb = 16
- phy_debug_render_shapes = 1
- phy_joint_anchor_1_x = 0
- phy_joint_anchor_1_y = 1
- phy_joint_anchor_2_x = 2
- phy_joint_anchor_2_y = 3
- phy_joint_angle = 8
- phy_joint_angle_limits = 21
- phy_joint_damping_ratio = 17
- phy_joint_frequency = 18
- phy_joint_length_1 = 15
- phy_joint_length_2 = 16
- phy_joint_lower_angle_limit = 19
- phy_joint_max_force = 24
- phy_joint_max_length = 22
- phy_joint_max_motor_force = 14
- phy_joint_max_motor_torque = 10
- phy_joint_max_torque = 23
- phy_joint_motor_force = 13
- phy_joint_motor_speed = 7
- phy_joint_motor_torque = 9
- phy_joint_reaction_force_x = 4
- phy_joint_reaction_force_y = 5
- phy_joint_reaction_torque = 6
- phy_joint_speed = 12
- phy_joint_translation = 11
- phy_joint_upper_angle_limit = 20
- phy_particle_data_flag_category = 16
- phy_particle_data_flag_color = 8
- phy_particle_data_flag_colour = 8
- phy_particle_data_flag_position = 2
- phy_particle_data_flag_typeflags = 1
- phy_particle_data_flag_velocity = 4
- phy_particle_flag_colormixing = 256
- phy_particle_flag_colourmixing = 256
- phy_particle_flag_elastic = 16
- phy_particle_flag_powder = 64
- phy_particle_flag_spring = 8
- phy_particle_flag_tensile = 128
- phy_particle_flag_viscous = 32
- phy_particle_flag_wall = 4
- phy_particle_flag_water = 0
- phy_particle_flag_zombie = 2
- phy_particle_group_flag_rigid = 2
- phy_particle_group_flag_solid = 1
- pi = 3.14159265
- pointer_invalid = FFFFFFFFFFFFFFFF
- pointer_null = null
- pr_linelist = 2
- pr_linestrip = 3
- pr_pointlist = 1
- pr_trianglefan = 6
- pr_trianglelist = 4
- pr_trianglestrip = 5
- ps_distr_gaussian = 1
- ps_distr_invgaussian = 2
- ps_distr_linear = 0
- ps_shape_diamond = 2
- ps_shape_ellipse = 1
- ps_shape_line = 3
- ps_shape_rectangle = 0
- pt_shape_circle = 5
- pt_shape_cloud = 11
- pt_shape_disk = 1
- pt_shape_explosion = 10
- pt_shape_flare = 8
- pt_shape_line = 3
- pt_shape_pixel = 0
- pt_shape_ring = 6
- pt_shape_smoke = 12
- pt_shape_snow = 13
- pt_shape_spark = 9
- pt_shape_sphere = 7
- pt_shape_square = 2
- pt_shape_star = 4
- seqaudiokey_loop = 0
- seqaudiokey_oneshot = 1
- seqdir_left = -1
- seqdir_right = 1
- seqinterpolation_assign = 0
- seqinterpolation_lerp = 1
- seqplay_loop = 1
- seqplay_oneshot = 0
- seqplay_pingpong = 2
- seqtracktype_audio = 2
- seqtracktype_bool = 5
- seqtracktype_clipmask = 8
- seqtracktype_clipmask_mask = 9
- seqtracktype_clipmask_subject = 10
- seqtracktype_color = 4
- seqtracktype_colour = 4
- seqtracktype_empty = 12
- seqtracktype_graphic = 1
- seqtracktype_group = 11
- seqtracktype_instance = 14
- seqtracktype_message = 15
- seqtracktype_moment = 16
- seqtracktype_real = 3
- seqtracktype_sequence = 7
- seqtracktype_spriteframes = 13
- seqtracktype_string = 6
- sprite_add_ext_error_cancelled = -2
- sprite_add_ext_error_decompressfailed = -5
- sprite_add_ext_error_loadfailed = -4
- sprite_add_ext_error_setupfailed = -6
- sprite_add_ext_error_spritenotfound = -3
- sprite_add_ext_error_unknown = -1
- spritespeed_framespergameframe = 1
- spritespeed_framespersecond = 0
- stencilop_decr = 8
- stencilop_decr_wrap = 5
- stencilop_incr = 7
- stencilop_incr_wrap = 4
- stencilop_invert = 6
- stencilop_keep = 1
- stencilop_replace = 3
- stencilop_zero = 2
- surface_r16float = 9
- surface_r32float = 10
- surface_r8unorm = 12
- surface_rg8unorm = 13
- surface_rgba16float = 14
- surface_rgba32float = 15
- surface_rgba4unorm = 11
- surface_rgba8unorm = 6
- tau = 6.28318531
- textalign_bottom = 2
- textalign_center = 1
- textalign_justify = 3
- textalign_left = 0
- textalign_middle = 1
- textalign_right = 2
- textalign_top = 0
- tf_anisotropic = 2
- tf_linear = 1
- tf_point = 0
- tile_flip = 536870912
- tile_index_mask = 524287
- tile_mirror = 268435456
- tile_rotate = 1073741824
- time_source_expire_after = 1
- time_source_expire_nearest = 0
- time_source_game = 1
- time_source_global = 0
- time_source_state_active = 1
- time_source_state_initial = 0
- time_source_state_paused = 2
- time_source_state_stopped = 3
- time_source_units_frames = 1
- time_source_units_seconds = 0
- timezone_local = 0
- timezone_utc = 1
- tm_countvsyncs = 1
- tm_sleep = 0
- tm_systemtiming = 2
- true = 1
- ty_real = 0
- ty_string = 1
- vertex_type_color = 5
- vertex_type_colour = 5
- vertex_type_float1 = 1
- vertex_type_float2 = 2
- vertex_type_float3 = 3
- vertex_type_float4 = 4
- vertex_type_ubyte4 = 6
- vertex_usage_binormal = 9
- vertex_usage_blendindices = 6
- vertex_usage_blendweight = 5
- vertex_usage_color = 2
- vertex_usage_colour = 2
- vertex_usage_depth = 13
- vertex_usage_fog = 12
- vertex_usage_normal = 3
- vertex_usage_position = 1
- vertex_usage_psize = 7
- vertex_usage_sample = 14
- vertex_usage_tangent = 8
- vertex_usage_texcoord = 4
- vertex_usage_textcoord = 4
- video_format_rgba = 0
- video_format_yuv = 1
- video_status_closed = 0
- video_status_paused = 3
- video_status_playing = 2
- video_status_preparing = 1
- vk_add = 107
- vk_alt = 18
- vk_anykey = 1
- vk_backspace = 8
- vk_control = 17
- vk_decimal = 110
- vk_delete = 46
- vk_divide = 111
- vk_down = 40
- vk_end = 35
- vk_enter = 13
- vk_escape = 27
- vk_f1 = 112
- vk_f10 = 121
- vk_f11 = 122
- vk_f12 = 123
- vk_f2 = 113
- vk_f3 = 114
- vk_f4 = 115
- vk_f5 = 116
- vk_f6 = 117
- vk_f7 = 118
- vk_f8 = 119
- vk_f9 = 120
- vk_home = 36
- vk_insert = 45
- vk_lalt = 164
- vk_lcontrol = 162
- vk_left = 37
- vk_lshift = 160
- vk_multiply = 106
- vk_nokey = 0
- vk_numpad0 = 96
- vk_numpad1 = 97
- vk_numpad2 = 98
- vk_numpad3 = 99
- vk_numpad4 = 100
- vk_numpad5 = 101
- vk_numpad6 = 102
- vk_numpad7 = 103
- vk_numpad8 = 104
- vk_numpad9 = 105
- vk_pagedown = 34
- vk_pageup = 33
- vk_pause = 19
- vk_printscreen = 44
- vk_ralt = 165
- vk_rcontrol = 163
- vk_return = 13
- vk_right = 39
- vk_rshift = 161
- vk_shift = 16
- vk_space = 32
- vk_subtract = 109
- vk_tab = 9
- vk_up = 38
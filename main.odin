package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"

import "codegen"
import "grammar"

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	_main()

	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}

_main :: proc() {
	if len(os.args) < 5 {
		fmt.println("parcelr LR0|SLR1|CLR1|LALR1 [grammar] [dir] [templates...]")
		return
	}

	type: grammar.Analyser
	switch os.args[1] {
	case "LR0":
		type = .LR0
	case "SLR1":
		type = .SLR1
	case "CLR1":
		type = .CLR1
	case "LALR1":
		type = .LALR1
	case:
		fmt.println("unknown grammar type\nsupported: LR0, SLR1, CLR1, LALR1")
		return
	}

	file, ok := os.read_entire_file(os.args[2])
	if !ok {
		fmt.println("could not parse grammar: unknown file")
		return
	}
	defer delete(file)

	g, err := grammar.parse_grammar(file)
	if err != {} {
		fmt.printf("could not parse grammar: %s\n", err)
		return
	}
	defer grammar.delete_grammar(g)
	grammar.print_grammar(g)
	fmt.println()

	empty := grammar.calc_empty_set(g)
	first := grammar.calc_first_sets(g, empty)
	follow := grammar.calc_follow_sets(g, first, empty)

	grammar.print_lookahead_table(g, first)
	fmt.println()
	grammar.print_lookahead_table(g, follow)
	fmt.println()

	defer {
		delete(empty)
		delete(first)
		delete(follow)
	}

	table, err2 := grammar.calc_table(g, type, empty, first, follow)
	if err2 != {} {
		fmt.printf("could not calculate table: %s\n", err2)
		return
	}
	defer grammar.delete_table(table)
	grammar.print_table(g, table)
	fmt.println()

	out_dir := os.args[3]

	for path, index in os.args[4:] {
		base := filepath.base(path)
		template, ok3 := os.read_entire_file(path)
		if !ok3 {
			fmt.println("could not parse template: unknown file")
			return
		}
		defer delete(template)

		dirs, ok4 := codegen.parse_template(transmute(string)template, "//")
		if !ok4 {
			fmt.println("could not parse template: mismatched braces")
			return
		}
		defer codegen.delete_directives(dirs)

		e, ok5 := codegen.eval(dirs, g, table, follow)
		if !ok5 {
			fmt.println("could not evaluate template")
			return
		}
		defer delete(e)

		os.write_entire_file(
			filepath.join({out_dir, base}, context.temp_allocator),
			transmute([]byte)e,
		)
	}
	fmt.println("SUCCESS")
}

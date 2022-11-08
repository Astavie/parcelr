package main

import "core:fmt"
import "core:os"

main :: proc() {
  if len(os.args) < 3 {
    fmt.println("parcelr LR0|SLR1|CLR1|LALR1 [file]")
    return
  }

  type : Analyser
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
    fmt.println("unknown file")
    return
  }

  g, _ := parse(file)

  print_grammar(g)
  fmt.println()

  empty := calc_empty_set(g)
  first := calc_first_sets(g, empty)
  follow := calc_follow_sets(g, first, empty)
  
  print_lookahead_table(g, first)
  fmt.println()
  print_lookahead_table(g, follow)
  fmt.println()

  table := calc_table(g, type, empty, first, follow)
  print_table(g, table)
  fmt.println()
 
  template, _ := os.read_entire_file("templates/template.odin")
  dirs,     _ := parse_template(transmute(string)template, "//")

  e, _ := eval(dirs, g, table)
  os.write_entire_file("out", transmute([]byte)e)
}

package main

import "core:fmt"
import "core:os"

main :: proc() {
  if len(os.args) < 3 {
    fmt.println("parcelr LR0|SLR1|CLR1|LALR1 [file]")
    return
  }

  type : analyser
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

  lexemes := calc_lexemes(g)
  empty := calc_empty_set(g)
  first := calc_first_sets(g, lexemes, empty)
  follow := calc_follow_sets(g, first, empty)

  table := calc_table(g, type, first, follow)
  print_table(g, table)
}

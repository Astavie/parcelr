package main

import "core:fmt"
import "core:os"

main :: proc() {
  if len(os.args) < 2 {
    fmt.println("parcelr [file]")
    return
  }

  file, ok := os.read_entire_file(os.args[1])
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

  table := calc_table(g, .LR0, first, follow)

  print_table(g, table)
}

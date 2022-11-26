package grammar

import "core:fmt"

print_rule :: proc(g : Grammar, r : RuleDefinition) {
  fmt.printf("%s -> ", g.symbols[r.lhs].name)
  for symbol in r.rhs {
    fmt.printf("%s ", g.symbols[symbol].name)
  }
  fmt.println(".")
}

print_grammar :: proc(g : Grammar) {
  for rule in g.rules {
    print_rule(g, rule)
  }
}

print_table :: proc(g : Grammar, t : Table) {
  for entry, idx in t {
    fmt.println(idx)
    for sym, i in g.symbols {
      name := sym.name
      symbol := Symbol(i)
      if !(symbol in entry) {
        /* fmt.printf("  %s: panic\n", name) */
        continue
      }

      switch v in entry[symbol] {
        case Reduce:
          if v == Reduce(START) {
            fmt.printf("  %s: accept\n", name)
          } else {
            fmt.printf("  %s: reduce ", name)
            print_rule(g, g.rules[v])
          }
        case Shift:
          fmt.printf("  %s: shift %d\n", name, v)
      }
    }
  }
}

print_lookahead :: proc(g : Grammar, set : Lookahead) {
  for lex in LEX_MIN..=LEX_MAX {
    if !(lex in set) do continue
    fmt.printf("%s ", g.symbols[g.lexemes[lex]].name)
  }
  fmt.println()
}

print_lookahead_table :: proc(g : Grammar, sets : []Lookahead) {
  for set, idx in sets {
    fmt.printf("%s: ", g.symbols[idx].name)
    print_lookahead(g, set)
  }
}


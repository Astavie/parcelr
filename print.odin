package main

import "core:fmt"

print_rule :: proc(g : grammar, r : rule) {
  fmt.printf("%s -> ", g.names[r.lhs])
  for sym in r.rhs {
    fmt.printf("%s ", g.names[sym])
  }
  fmt.print(".")
}

print_grammar :: proc(g : grammar) {
  for r in g.rules {
    print_rule(g, r)
    fmt.println()
  }
}

print_table :: proc(g : grammar, t : table) {
  for entry, idx in t {
    fmt.println(idx)
    for name, i in g.names {
      sym := symbol(i)
      if !(sym in entry) {
        /* fmt.printf("  %s: panic\n", name) */
        continue
      }

      switch v in entry[sym] {
        case reduce:
          if v == start_rule {
            fmt.printf("  %s: accept\n", name)
          } else {
            fmt.printf("  %s: reduce ", name)
            print_rule(g, g.rules[v])
            fmt.println()
          }
        case shift:
          fmt.printf("  %s: shift %d\n", name, v)
      }
    }
    if NONE in entry {
      switch v in entry[NONE] {
        case reduce:
          if v == start_rule {
            fmt.print("  $: accept\n")
          } else {
            fmt.print("  $: reduce ")
            print_rule(g, g.rules[v])
            fmt.println()
          }
        case shift:
          fmt.printf("  $: shift %d\n", v)
      }
    } else {
      /* fmt.println("  $: panic") */
    }
  }
}

print_symbset :: proc(g : grammar, set : symbset) {
  for symb in ROOT..=NONE {
    if !(symb in set) do continue
    if symb == NONE {
      fmt.print("$ ")
    } else {
      fmt.printf("%s ", g.names[symb])
    }
  }
  fmt.println()
}

print_symbsets :: proc(g : grammar, sets : []symbset) {
  for set, idx in sets {
    fmt.printf("%s: ", g.names[idx])
    print_symbset(g, set)
  }
}


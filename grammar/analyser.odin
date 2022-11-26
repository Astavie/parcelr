package grammar

import "core:slice"
import "core:fmt"

Item :: struct {
  rule      : Rule,
  index     : int,
  lookahead : Lookahead,
}

LEX_MIN :: Lexeme(0)
LEX_MAX :: Lexeme(127)
Lookahead :: bit_set[LEX_MIN..=LEX_MAX]

Decision :: union #no_nil { Reduce, Shift }

Table :: []map[Symbol]Decision

Reduce :: distinct Rule // number refers to rule
Shift  :: distinct int  // number refers to state

Analyser :: enum { LR0, SLR1, CLR1, LALR1 }

predict :: proc(g : Grammar, type : Analyser, set : []Item, empty: map[Symbol]void, first : []Lookahead, follow : []Lookahead) -> []Item {
  stack      := slice.clone_to_dynamic(set)
  prediction := slice.clone_to_dynamic(set)

  all_symbols := transmute(Lookahead)(max(u128) >> u8(128 - len(g.lexemes)))

  for len(stack) > 0 {
    item := pop(&stack)

    rhs := g.rules[item.rule].rhs
    if len(rhs) <= item.index do continue

    sym := rhs[item.index]
    lah := Lookahead{}
    i := item.index + 1
    for ; i < len(rhs); i += 1 {
      lah += first[rhs[i]]
      if !(rhs[i] in empty) do break
    }
    if i == len(rhs) do lah += item.lookahead

    a: for def, idx in g.rules {
      if sym != def.lhs do continue
      rule := Rule(idx)

      switch type {
        case .LALR1:
          item := Item { rule, 0, lah }

          for prev, idx in prediction {
            if prev.rule == item.rule && prev.index == item.index {
              // still evaluate an equivalent item if its lookahead contains new elements
              if !(prev.lookahead >= lah) {
                prediction[idx].lookahead += lah
                append(&stack, item)
              }
              continue a
            }
          }

          append(&prediction, item)
          append(&stack, item)
        case .CLR1:
          for next in LEX_MIN..=LEX_MAX {
            if !(next in lah) do continue
            
            item := Item { rule, 0, { next } }
            if slice.contains(prediction[:], item) do continue

            append(&prediction, item)
            append(&stack, item)
          }
        case .SLR1:
          item := Item { rule, 0, follow[g.rules[idx].lhs] }
          if slice.contains(prediction[:], item) do continue
          
          append(&prediction, item)
          append(&stack, item)
        case .LR0:
          item := Item { rule, 0, all_symbols }
          if slice.contains(prediction[:], item) do continue
          
          append(&prediction, item)
          append(&stack, item)
      }
    }
  }

  delete(stack)
  return prediction[:]
}

inject_sort :: proc(a : $T/^[dynamic]$E, b : E, less : proc(a, b : E) -> bool) {
  append(a, b)
  for j := len(a) - 1; j > 0 && less(a[j], a[j - 1]); j -= 1 {
    slice.swap(a[:], j, j - 1)
  }
}

partition :: proc(g : Grammar, set : []Item) -> map[Symbol][]Item {
  groups := make(map[Symbol][dynamic]Item)

  for item in set {
    sym := ROOT
    put := item

    rhs := g.rules[item.rule].rhs
    if (len(rhs) > item.index) {
      sym = rhs[item.index]
      put = { item.rule, item.index + 1, item.lookahead }
    }

    if sym in groups {
      inject_sort(&groups[sym], put, proc(a, b: Item) -> bool {
        if a.rule < b.rule do return true
        if a.rule > b.rule do return false
        if a.index < b.index do return true
        if a.index > b.index do return false
        if transmute(u128)a.lookahead < transmute(u128)b.lookahead do return true
        return false
      })
    } else {
      is := make([dynamic]Item)
      append(&is, put)
      groups[sym] = is
    }
  }

  final_groups := make(map[Symbol][]Item, len(groups))
  for sym, group in groups {
    final_groups[sym] = group[:]
  }

  delete(groups)
  return final_groups
}

indexof_slice :: proc(a : $T/[][]$E, b : []E) -> (int, bool) {
  for elem, idx in a {
    if slice.equal(elem, b) do return idx, true
  }
  return ---, false
}

delete_table :: proc(t: Table) {
  for row in t {
    delete(row)
  }
  delete(t)
}

calc_table :: proc(g : Grammar, type : Analyser, empty: map[Symbol]void, first : []Lookahead, follow : []Lookahead) -> (Table, Error) {
  
  StackEntry :: struct {
    set   : []Item,
    index : int,
  }

  find_entry :: proc(stack : []StackEntry, elem : []Item) -> (int, bool) {
    for entry in stack {
      if slice.equal(entry.set, elem) do return entry.index, true
    }
    return ---, false
  }

  table    := make([dynamic]map[Symbol]Decision)
  stack    := make([dynamic]StackEntry)
  start    := predict(g, type, {{ Rule(0), 0, { EOF } }}, empty, first, follow)
  append(&stack, StackEntry { start, 0 })
  append(&table, make(map[Symbol]Decision))
  
  // the following are used for LALR(1) parsing
  final_sets := make([dynamic][]Item)
  clone := slice.clone(start)
  for item in &clone do item.lookahead = {}
  append(&final_sets, clone)

  defer {
    for entry in stack do delete(entry.set)
    for set in final_sets do delete(set)
    delete(final_sets)
    delete(stack)
  }

  for _i := 0; _i < len(stack); _i += 1 {
    entry := stack[_i]
    set   := entry.set
    i     := entry.index
 
    pset := predict(g, type, set, empty, first, follow)
    defer delete(pset)

    part := partition(g, pset)
    defer delete(part)

    for sym, items in part {
      if sym == ROOT {
        defer delete(items)
        for item in items {
          e := Reduce(item.rule)
          for lex in LEX_MIN..=LEX_MAX {
            if !(lex in item.lookahead) do continue
            next := g.lexemes[lex]
            if next in table[i] && table[i][next] != e {
              // TODO better errors
              switch in table[i][next] {
                case Shift:
                  delete_table(table[:])
                  return ---, "SHIFT/REDUCE CONFLICT"
                case Reduce:
                  delete_table(table[:])
                  return ---, "REDUCE/REDUCE CONFLICT"
              }
            }
            table[i][next] = e
          }
        }
      } else {
        if sym in table[i] {
          // TODO better errors
          switch in table[i][sym] {
            case Shift:
              // we assume we are merging two identical shifts
            case Reduce:
              delete_table(table[:])
              return ---, "SHIFT/REDUCE CONFLICT"
          }
        }

        if idx, ok := find_entry(stack[:], items); ok {
          // we found an identical state
          table[i][sym] = Shift(idx)
          delete(items)
        } else {
          idx : int
          ok := false
          if type == .LALR1 {
            // check if states can be merged
            clone := slice.clone(items)
            for item in &clone do item.lookahead = {}
          
            idx, ok = indexof_slice(final_sets[:], clone)
            
            if ok {
              delete(clone)
            } else {
              append(&final_sets, clone)
            }
          }
          
          if ok {
            // mark entry to be merged with a previous state
            table[i][sym] = Shift(idx)
            append(&stack, StackEntry { items, idx })
          } else {
            // create a new state
            table[i][sym] = Shift(len(table))
            append(&stack, StackEntry { items, len(table) })
            append(&table, make(map[Symbol]Decision))
          }
        }
      }
    }
  }

  return table[:], {}
}

contains_all :: proc(a : $T/map[$K]$V, b : []K) -> bool {
  for elem in b {
    if !(elem in a) do return false
  }
  return true
}

calc_empty_set :: proc(g : Grammar) -> map[Symbol]void {
  symbols := make(map[Symbol]void)
  for rule in g.rules {
    if len(rule.rhs) == 0 do symbols[rule.lhs] = {}
  }

  for {
    n := len(symbols)
    for rule in g.rules {
      if contains_all(symbols, rule.rhs) do symbols[rule.lhs] = {}
    }
    if len(symbols) == n do break
  }

  return symbols
}

calc_first_sets :: proc(g : Grammar, empty : map[Symbol]void) -> []Lookahead {
  symbols := make([]Lookahead, len(g.symbols))
  routes  := make(map[[2]Symbol]void)

  defer delete(routes)

  for i in 0..<len(g.lexemes) {
    symbol := g.lexemes[i]
    symbols[symbol] += { Lexeme(i) }
  }

  for rule in g.rules {
    for symbol in rule.rhs {
      routes[{ rule.lhs, symbol }] = {}
      if !(symbol in empty) do break
    }
  }

  for rep := true; rep; {
    rep = false
    for route in routes {
      n := card(symbols[route[0]])
      symbols[route[0]] += symbols[route[1]]
      rep |= card(symbols[route[0]]) > n
    }
  }

  return symbols
}

calc_follow_sets :: proc(g : Grammar, first : []Lookahead, empty : map[Symbol]void) -> []Lookahead {
  symbols := make([]Lookahead, len(g.symbols))
  routes := make(map[[2]Symbol]void)

  defer delete(routes)

  symbols[ROOT] += { EOF }

  for rule in g.rules {
    for symbol, idx in rule.rhs {
      max := idx + 1
      for symb2 in rule.rhs[max:] {
        symbols[symbol] += first[symb2]
        if !(symb2 in empty) do break
        max += 1
      }
      if (max == len(rule.rhs)) {
        routes[{ symbol, rule.lhs }] = {}
      }
    }
  }

  for rep := true; rep; {
    rep = false
    for route in routes {
      n := card(symbols[route[0]])
      symbols[route[0]] += symbols[route[1]]
      rep |= card(symbols[route[0]]) > n
    }
  }

  return symbols
}

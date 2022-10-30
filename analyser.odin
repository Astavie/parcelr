package main

import "core:slice"
import "core:fmt"

ROOT :: symbol(0)
NONE :: symbol(127)

item :: struct {
  rule      : int,
  indx      : int,
  lookahead : symbset,
}

start_rule :: -1
start_item :: item { start_rule, 0, { NONE } }

void    :: struct{}
itemset :: []item
symbset :: bit_set[ROOT..=NONE]

reduce :: distinct int // number refers to rule
shift  :: distinct int // number refers to state

decision :: union #no_nil { reduce, shift }

table :: []map[symbol]decision

analyser :: enum { LR0, SLR1, CLR1, LALR1 }

predict :: proc(g : grammar, type : analyser, set : itemset, first : []symbset, follow : []symbset) -> itemset {
  stack      := slice.clone_to_dynamic(set)
  prediction := slice.clone_to_dynamic(set)

  all_symbols := transmute(symbset)(max(u128) >> u8(128 - len(g.names))) + { NONE }

  for len(stack) > 0 {
    itm := pop(&stack)

    rhs : []symbol = { ROOT }
    if itm.rule != start_rule do rhs = g.rules[itm.rule].rhs
    if len(rhs) <= itm.indx   do continue

    sym := rhs[itm.indx]
    lah := itm.lookahead
    if len(rhs) > itm.indx + 1 do lah = first[rhs[itm.indx + 1]]

    a: for rule, idx in g.rules {
      if sym != rule.lhs do continue

      switch type {
        case .LALR1:
          itm := item { idx, 0, lah }

          for prev, idx in prediction {
            if prev.rule == itm.rule && prev.indx == itm.indx {
              prediction[idx].lookahead += lah
              continue a
            }
          }

          append(&prediction, itm)
          append(&stack, itm)
        case .CLR1:
          for next in ROOT..=NONE {
            if !(next in lah) do continue
            
            itm := item { idx, 0, { next } }
            if slice.contains(prediction[:], itm) do continue

            append(&prediction, itm)
            append(&stack, itm)
          }
        case .SLR1:
          itm := item { idx, 0, follow[g.rules[idx].lhs] }
          if slice.contains(prediction[:], itm) do continue
          
          append(&prediction, itm)
          append(&stack, itm)
        case .LR0:
          itm := item { idx, 0, all_symbols }
          if slice.contains(prediction[:], itm) do continue
          
          append(&prediction, itm)
          append(&stack, itm)
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

partition :: proc(g : grammar, set : itemset) -> map[symbol]itemset {
  groups := make(map[symbol][dynamic]item)

  for itm in set {
    sym := NONE
    put := itm

    rhs : []symbol = { ROOT }
    if itm.rule != start_rule do rhs = g.rules[itm.rule].rhs
    if (len(rhs) > itm.indx) {
      sym = rhs[itm.indx]
      put = { itm.rule, itm.indx + 1, itm.lookahead }
    }

    if sym in groups {
      inject_sort(&groups[sym], put, proc(a, b: item) -> bool {
        if a.rule < b.rule do return true
        if a.rule > b.rule do return false
        if a.indx < b.indx do return true
        if a.indx > b.indx do return false
        if transmute(u128)a.lookahead < transmute(u128)b.lookahead do return true
        return false
      })
    } else {
      is := make([dynamic]item)
      append(&is, put)
      groups[sym] = is
    }
  }

  final_groups := make(map[symbol]itemset, len(groups))
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

calc_table :: proc(g : grammar, type : analyser, first : []symbset, follow : []symbset) -> table {
  table    := make([dynamic]map[symbol]decision)
  itemsets := make([dynamic]itemset)
  start    := predict(g, type, { start_item }, first, follow)
  append(&itemsets, start)
  append(&table, make(map[symbol]decision))
  
  // the following are used for LALR(1) parsing
  itemsets_nolook := make([dynamic]itemset)
  unmerged := make([dynamic]int)
  merges   := make([dynamic][2]int)
  clone := slice.clone(start)
  for itm in &clone do itm.lookahead = {}
  append(&itemsets_nolook, clone)
  append(&unmerged, 0)

  defer {
    for set in itemsets do delete(set)
    for set in itemsets_nolook do delete(set)
    delete(itemsets)
    delete(unmerged)
    delete(itemsets_nolook)
    delete(merges)
  }

  for i in 0..<len(itemsets) {
    set := itemsets[i]
 
    pset := predict(g, type, set, first, follow)
    defer delete(pset)

    part := partition(g, pset)
    defer delete(part)

    for sym, items in part {
      if sym == NONE {
        defer delete(items)
        for itm in items {
          e := reduce(itm.rule)
          for next in ROOT..=NONE {
            if !(next in itm.lookahead) do continue
            if next in table[i] && table[i][next] != e {
              // TODO better errors
              switch v in table[i][next] {
                case shift:
                  panic("SHIFT/REDUCE CONFLICT")
                case reduce:
                  panic("REDUCE/REDUCE CONFLICT")
              }
            }
            table[i][next] = e
          }
        }
      } else {
        if sym in table[i] {
          // TODO better errors
          panic("SHIFT/REDUCE CONFLICT")
        }

        if idx, ok := indexof_slice(itemsets[:], items); ok {
          table[i][sym] = shift(unmerged[idx])
          delete(items)
        } else {
          idx : int
          ok := false
          if type == .LALR1 {
            clone := slice.clone(items)
            for itm in &clone do itm.lookahead = {}
          
            idx, ok = indexof_slice(itemsets_nolook[:], clone)
            
            append(&itemsets_nolook, clone)
          }
          
          if ok {
            table[i][sym] = shift(unmerged[idx])
            append(&merges, [2]int{ len(itemsets), idx })
            append(&unmerged, unmerged[idx])
          } else {
            table[i][sym] = shift(len(itemsets) - len(merges))
            append(&unmerged, len(itemsets) - len(merges))
          }

          append(&itemsets, items)
          append(&table, make(map[symbol]decision))
        }
      }
    }
  }

  for idx := len(merges) - 1; idx >= 0; idx -= 1 {
    from := merges[idx][0]
    into := merges[idx][1]
    for sym, dec in table[from] {
      if sym in table[into] && table[into][sym] != dec {
        // TODO better errors
        panic("REDUCE/REDUCE CONFLICT")
      }
      table[into][sym] = dec
    }
    delete(itemsets[from])
    delete(table[from])
    ordered_remove(&itemsets, from)
    ordered_remove(&table,    from)
  }

  return table[:]
}

calc_lexemes :: proc(g : grammar) -> symbset {
  notlexemes := symbset{}
  lexemes := symbset{}

  for r in g.rules {
    notlexemes += { r.lhs }
  }

  for _, idx in g.names {
    sym := symbol(idx)
    if !(sym in notlexemes) do lexemes += { sym }
  }

  return lexemes
}

contains_all :: proc(a : $T/bit_set[$E], b : []E) -> bool {
  for elem in b {
    if !(elem in a) do return false
  }
  return true
}

calc_empty_set :: proc(g : grammar) -> symbset {
  symbols := symbset{}
  for r in g.rules {
    if len(r.rhs) == 0 do symbols += { r.lhs }
  }

  for {
    n := card(symbols)
    for r in g.rules {
      if contains_all(symbols, r.rhs) do symbols += { r.lhs }
    }
    if card(symbols) == n do break
  }

  return symbols
}

calc_first_sets :: proc(g : grammar, lexemes, empty : symbset) -> []symbset {
  symbols := make([]symbset, len(g.names))
  routes  := make(map[[2]symbol]void)

  defer delete(routes)

  for i in 0..<len(g.names) {
    sym := symbol(i)
    if sym in lexemes {
      symbols[sym] += { sym }
    }
  }

  for r in g.rules {
    for symb in r.rhs {
      routes[{ r.lhs, symb }] = {}
      if !(symb in empty) do break
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

calc_follow_sets :: proc(g : grammar, first : []symbset, empty : symbset) -> []symbset {
  symbols := make([]symbset, len(g.names))
  routes := make(map[[2]symbol]void)

  defer delete(routes)

  for r in g.rules {
    for symb, idx in r.rhs {
      max := idx + 1
      for symb2, idx2 in r.rhs[max:] {
        symbols[symb] += first[symb2]
        if !(symb2 in empty) do break
        max = idx2 + 1
      }
      if (max == len(r.rhs)) {
        routes[{ symb, r.lhs }] = {}
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

package codegen

import "core:strings"
import "core:fmt"

import "../grammar"

Globals :: struct {
  state:  []StateVal,
  symbol: []Symbol,
  lexeme: []Symbol,
  preamble: string,
}

make_single :: proc(e: $E) -> []E {
  s := make([]E, 1)
  s[0] = e
  return s
}

make_globals :: proc(g: grammar.Grammar, table: grammar.Table) -> Globals {
  globals := Globals {
    make([]StateVal, len(table)),
    g.symbols[1:],
    make([]Symbol, len(g.lexemes) - 1),
    g.preamble,
  }

  for lex, i in g.lexemes[1:] {
    globals.lexeme[i] = g.symbols[lex]
  }

  for i in 0..<len(table) {
    lookup := make(map[grammar.Decision]int)
    defer delete(lookup)
    lah := make([dynamic]LookaheadVal)

    for symbol, decision in table[i] {
      if k, ok := lookup[decision]; ok {
        clone := make([]Symbol, len(lah[k].symbol) + 1)
        copy(clone, lah[k].symbol)
        clone[len(clone) - 1] = g.symbols[symbol]

        delete(lah[k].symbol)
        lah[k].symbol = clone
        continue
      }

      j := len(lah)
      lookup[decision] = j
      append(&lah, LookaheadVal { make_single(g.symbols[symbol]), nil, nil, nil })

      switch v in decision {
        case grammar.Reduce:
          if v == grammar.Reduce(grammar.START) {
            lah[j].accept = {{}}
          } else {
            rule := g.rules[v]
            lhs := g.symbols[rule.lhs]
            rhs := make([]Symbol, len(rule.rhs))
            for k in 0..<len(rhs) {
              rhs[k] = g.symbols[rule.rhs[k]]
            }
            lah[j].reduce = make_single(ReduceVal{ lhs, rhs, rule.code })
          }
        case grammar.Shift:
          lah[j].shift = make_single(int(v))
      }
    }

    globals.state[i] = { i, lah[:] }
  }
  return globals
}

StackElement :: struct {
  var: string,
  value: Value,
}

eval :: proc(directives: []Directive, g: grammar.Grammar, table: grammar.Table) -> (string, bool) {
  globals := make_globals(g, table)

  stack := make([dynamic]StackElement)
  append(&stack, StackElement{ "state",  globals.state  })
  append(&stack, StackElement{ "symbol", globals.symbol })
  append(&stack, StackElement{ "lexeme", globals.lexeme })
  append(&stack, StackElement{ "preamble", globals.preamble })

  defer {
    delete_value(stack[0].value)
    // delete_value(stack[1].value) // do note delete, directly taken from Grammar
    delete_value(stack[2].value)
    delete_value(stack[3].value)
    delete(stack)
  }

  sb := strings.builder_make_none()

  dirs := directives
  ok := _eval(&sb, &stack, &dirs, false)
  if !ok {
    strings.builder_destroy(&sb)
    return ---, false;
  }
  return strings.to_string(sb), true
}

_skip :: proc(directives: ^[]Directive) -> bool {
  for len(directives) > 0 {
    dir := directives[0]
    directives^ = directives[1:]
    #partial switch v in dir {
      case Start:
        _skip(directives) or_return
      case End:
        return true
    }
  }
  return false
}

_eval :: proc(sb: ^strings.Builder, stack: ^[dynamic]StackElement, directives: ^[]Directive, last: bool) -> bool {
  for len(directives) > 0 {
    dir := directives[0]
    directives^ = directives[1:]

    ends_with :: proc(s: $T/[]$E, e: E) -> bool {
      return len(s) > 0 && s[len(s) - 1] == e
    }

    switch v in dir {
      case Write:
        if v.newline && len(sb.buf) > 0 {
          fmt.sbprintln(sb)
        }

        if strings.trim_space(v.before) != {} || ends_with(sb.buf[:], '\n') {
          fmt.sbprint(sb, v.before)
        }

        if v.separator && last do continue

        fmt.sbprint(sb, v.after)
        for varlit in v.vars {
          val := get_value(varlit.var, stack[:]) or_return
          defer if len(varlit.var) > 1 do delete_value_slice(val)

          print_value(sb, val) or_return
          fmt.sbprint(sb, varlit.lit)
        }
      case Start:
        val := get_value(v.var, stack[:]) or_return
        defer if len(v.var) > 1 do delete_value_slice(val)

        it, _ := as_slice(val, true)
        for val, idx in iterate_values(&it) {
          append(stack, StackElement{ v.name, val })
          if v.index != {} do append(stack, StackElement{ v.index, idx })
          
          dirs := directives^;
          _eval(sb, stack, &dirs, idx == it.len - 1) or_return
          
          if v.index != {} do pop(stack)
          pop(stack)
        }
        _skip(directives) or_return
      case End:
        return true
    }
  }
  return true
}

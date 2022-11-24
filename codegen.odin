package main

import "core:strconv"
import "core:slice"
import "core:strings"
import "core:fmt"

Var :: []string

Start :: struct {
  var: Var,
  name: string,
}

WriteEntry :: struct {
  var: Var,
  lit: string,
}

Write :: struct {
  before: string,
  after:  string,
  vars: []WriteEntry,
  newline: bool,
  separator: bool,
}

End :: distinct void

Directive :: union #no_nil { Start, Write, End }

Token :: struct {
  name:       string,
  enum_value: string,
}

LookaheadVal :: struct {
  symbol: []Token,
  accept: []void,
  shift:  []int,
  reduce: []ReduceVal,
}

ReduceVal :: struct {
  lhs: Token,
  rhs: []Token,
}

StateVal :: struct {
  index:     int,
  lookahead: []LookaheadVal,
}

Value :: union #no_nil { void, int, string, LookaheadVal, ReduceVal, StateVal, Token, []void, []int, []string, []LookaheadVal, []ReduceVal, []StateVal, []Token }

Globals :: struct {
  state:  []StateVal,
  symbol: []Token,
  lexeme: []Token,
}

make_single :: proc(e: $E) -> []E {
  s := make([]E, 1)
  s[0] = e
  return s
}

make_globals :: proc(g: Grammar, table: Table) -> Globals {
  zip :: proc(a: $T/[]$A, b: $U/[]$B, f: proc(a: A, b: B) -> $C) -> []C {
    ret := make([]C, min(len(a), len(b)))
    for _, i in ret {
      ret[i] = f(a[i], b[i])
    }
    return ret
  }

  globals := Globals {
    make([]StateVal, len(table)),
    zip(g.symbols[1:], g.enum_names[1:],
      proc(a, b: string) -> Token { return Token{ a, b } }),
    make([]Token, len(g.lexemes) - 1),
  }

  for lex, i in g.lexemes[1:] {
    globals.lexeme[i] = Token { g.symbols[lex], g.enum_names[lex] }
  }

  for i in 0..<len(table) {
    lookup := make(map[Decision]int)
    defer delete(lookup)
    lah := make([dynamic]LookaheadVal)

    for symbol, decision in table[i] {
      if k, ok := lookup[decision]; ok {
        clone := make([]Token, len(lah[k].symbol) + 1)
        copy(clone, lah[k].symbol)
        clone[len(clone) - 1] = { g.symbols[symbol], g.enum_names[symbol] }

        delete(lah[k].symbol)
        lah[k].symbol = clone
        continue
      }

      j := len(lah)
      lookup[decision] = j
      append(&lah, LookaheadVal { make_single(Token{ g.symbols[symbol], g.enum_names[symbol] }), nil, nil, nil })

      switch v in decision {
        case Reduce:
          if v == Reduce(START) {
            lah[j].accept = {{}}
          } else {
            rule := g.rules[v]
            lhs := Token{ g.symbols[rule.lhs], g.enum_names[rule.lhs] }
            rhs := make([]Token, len(rule.rhs))
            for k in 0..<len(rhs) {
              rhs[k] = { g.symbols[rule.rhs[k]], g.enum_names[rule.rhs[k]] }
            }
            lah[j].reduce = make_single(ReduceVal{ lhs, rhs })
          }
        case Shift:
          lah[j].shift = make_single(int(v))
      }
    }

    globals.state[i] = { i, lah[:] }
  }
  return globals
}

get_child :: proc(val: Value, s: string) -> (v: Value, ok: bool) {
  #partial switch v in val {
    case LookaheadVal:
      switch s {
        case "symbol":
          return slice.clone(v.symbol), true
        case "accept":
          return v.accept, true
        case "shift":
          return slice.clone(v.shift), true
        case "reduce":
          return slice.clone(v.reduce), true
      }
    case ReduceVal:
      switch s {
        case "lhs":
          return v.lhs, true
        case "rhs":
          return slice.clone(v.rhs), true
      }
    case StateVal:
      switch s {
        case "index":
          return v.index, true
        case "lookahead":
          return slice.clone(v.lookahead), true
      }
    case Token:
      switch s {
        case "name":
          return v.name, true
        case "enum":
          return v.enum_value, true
      }
    case []void:
      switch s {
        case "length":
          return len(v), true
      }
    case []int:
      switch s {
        case "length":
          return len(v), true
        case:
          i := strconv.parse_int(s, 10) or_return
          return slice.count(v, i), true
      }
    case []string:
      switch s {
        case "length":
          return len(v), true
        case:
          return slice.count(v, s), true
      }
    case []LookaheadVal, []ReduceVal, []StateVal, []Token:
      it, _ := as_slice(val, false)
      switch s {
        case "length":
          return it.len, true
        case:
          children := make([dynamic]Value)
          defer delete(children)
          for elem in iterate_values(&it) {
            child := get_child(elem, s) or_return
            if it2, ok := as_slice(child, false); ok {
              defer delete_value_slice(child)
              for elem2 in iterate_values(&it2) {
                append(&children, elem2)
              }
            } else {
              append(&children, child)
            }
          }
          return slice_to_value(children[:]), true
      }
  }
  return ---, false
}

delete_value :: proc(val: Value) {
  #partial switch v in val {
    case LookaheadVal:
      delete_value(v.reduce)
      delete(v.shift)
      delete(v.symbol)
    case ReduceVal:
      delete(v.rhs)
    case StateVal:
      delete_value(v.lookahead)
    case:
      if it, ok := as_slice(val, false); ok {
        for v in iterate_values(&it) {
          delete_value(v)
        }
        delete_value_slice(val)
      }
  }
}

delete_value_slice :: proc(val: Value) {
  #partial switch v in val {
    case []LookaheadVal:
      delete(v)
    case []ReduceVal:
      delete(v)
    case []StateVal:
      delete(v)
    case []Token:
      delete(v)
    case []int:
      delete(v)
    case []string:
      delete(v)
  }
}

cast_slice :: proc(s: $T/[]$E, $A: typeid) -> []A {
  slice := make([]A, len(s))
  for e, i in s {
    slice[i] = e.(A)
  }
  return slice
}

slice_to_value :: proc(s: []Value) -> Value {
  if len(s) == 0 do return []void{}

  #partial switch v in s[0] {
    case void:
      return cast_slice(s, void)
    case int:
      return cast_slice(s, int)
    case string:
      return cast_slice(s, string)
    case LookaheadVal:
      return cast_slice(s, LookaheadVal)
    case ReduceVal:
      return cast_slice(s, ReduceVal)
    case StateVal:
      return cast_slice(s, StateVal)
    case Token:
      return cast_slice(s, Token)
  }

  return ---
}

ValueIterator :: struct {
  len: int,
  indx: int,
  data: Value,
}

iterate_values :: proc(val: ^ValueIterator) -> (Value, int, bool) {
  
  iterate :: proc(s: $T/[]$E, indx: ^int) -> (E, int, bool) {
    if indx^ >= len(s) do return ---, ---, false
    e := s[indx^]
    indx^ += 1
    return e, indx^ - 1, true
  }

  #partial switch v in val.data {
    case []void:
      return iterate(v, &val.indx)
    case []int:
      return iterate(v, &val.indx)
    case []string:
      return iterate(v, &val.indx)
    case []LookaheadVal:
      return iterate(v, &val.indx)
    case []ReduceVal:
      return iterate(v, &val.indx)
    case []StateVal:
      return iterate(v, &val.indx)
    case []Token:
      return iterate(v, &val.indx)
  }
  return ---, ---, false
}

as_slice :: proc(val: Value, ints: bool) -> (ValueIterator, bool) {
  #partial switch v in val {
    case int:
      if ints {
        // return a slice of N voids
        return { v, 0, slice.from_ptr((^void)(nil), v) }, true
      }
    case []void, []int, []string, []LookaheadVal, []ReduceVal, []StateVal, []Token:
      p := val
      return { len((^[]void)(&p)^), 0, v }, true
  }
  return ---, false
}

get_value :: proc(var: Var, stack: []StackElement) -> (value: Value, ok: bool) {
  for i := len(stack) - 1; i >= 0; i -= 1 {
    if var[0] != stack[i].var do continue
    
    value = stack[i].value
    for s, i in var[1:] {
      parent := value
      defer if i > 0 do delete_value_slice(parent)
      value = get_child(value, s) or_return
    }
    return value, true
  }
  return ---, false
}

print_value :: proc(sb: ^strings.Builder, val: Value) -> bool {
  #partial switch v in val {
    case int, string:
      fmt.sbprint(sb, v)
      return true
    case ReduceVal:
      fmt.sbprintf(sb, "%s -> ", v.lhs.name)
      for token in v.rhs {
        fmt.sbprintf(sb, "%s ", token.name)
      }
      fmt.sbprint(sb, ".")
      return true
  }
  return false
}

StackElement :: struct {
  var: string,
  value: Value,
}

eval :: proc(directives: []Directive, g: Grammar, table: Table) -> (string, bool) {
  globals := make_globals(g, table)

  stack := make([dynamic]StackElement)
  append(&stack, StackElement{ "state",  globals.state  })
  append(&stack, StackElement{ "symbol", globals.symbol })
  append(&stack, StackElement{ "lexeme", globals.lexeme })

  defer {
    delete_value(stack[0].value)
    delete_value(stack[1].value)
    delete_value(stack[2].value)
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

        it := as_slice(val, true) or_return
        for val, idx in iterate_values(&it) {
          append(stack, StackElement{ v.name, val })
          dirs := directives^;
          _eval(sb, stack, &dirs, idx == it.len - 1) or_return
          pop(stack)
        }
        _skip(directives) or_return
      case End:
        return true
    }
  }
  return true
}

delete_directives :: proc(dirs: []Directive) {
  for dir in dirs {
    switch d in dir {
      case Start:
        delete(d.var)
      case Write:
        for v in d.vars {
          delete(v.var)
        }
        delete(d.vars)
      case End:
    }
  }
  delete(dirs)
}

parse_template :: proc(template, prefix: string) -> ([]Directive, bool) {
  lines := strings.split_lines(template)
  defer delete(lines)

  directives := make([dynamic]Directive)

  for line in lines {
    i := strings.index(line, prefix)
    if i == -1 {
      append(&directives, Write{ line, {}, {}, true, false })
      continue
    }

    literal := line[0:i]
    directive := strings.trim_space(line[i + len(prefix):])
    
    space := strings.index_byte(directive, ' ')
    if space == -1 do space = len(directive)
    word := directive[0:space]

    switch word {
      case "":
        continue
      case "l", "w", "s":
        // write
        next := directive[2:]
        index := strings.index(next, "${")
        if index == -1 {
          append(&directives, Write{ literal, next, {}, word == "l", word == "s" })
          continue
        }

        first := next[0:index]

        entries := make([dynamic]WriteEntry)
        for index > -1 {
          end := strings.index(next[index + 2:], "}")
          if end == -1 {
            for entry in entries {
              delete(entry.var)
            }
            delete(entries)
            delete_directives(directives[:])
            return ---, false
          }

          var := strings.split(strings.trim_space(next[index + 2:index + 2 + end]), ".")
          
          next = next[index + 2 + end + 1:]
          index = strings.index(next, "${")
          lit := next
          if index != -1 do lit = next[0:index]

          append(&entries, WriteEntry{ var, lit })
        }

        append(&directives, Write{ literal, first, entries[:], word == "l", word == "s" })
      case "e":
        // end
        if strings.trim_space(literal) != {} do append(&directives, Write{ literal, {}, {}, true, false })
        append(&directives, End{})
      case "d":
        // delete
        continue
      case:
        // start
        var := strings.split(word, ".")

        name := var[len(var) - 1]
        if len(directive) > space {
          name = directive[space + 1:]
          space := strings.index_byte(name, ' ')
          if (space != -1) do name = name[0:space]
        }

        if strings.trim_space(literal) != {} do append(&directives, Write{ literal, {}, {}, true, false })
        append(&directives, Start{ var, name })
    }
  }

  return directives[:], true
}

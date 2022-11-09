package main

import "core:strings"
import "core:fmt"
import "core:runtime"
import "core:intrinsics"

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
  index: int,
  lookahead: []LookaheadVal,
}

Value      :: union #no_nil { void, int, string, LookaheadVal, ReduceVal, StateVal, Token, ValueSlice }
ValueSlice :: struct { type: u8, slice: []void }

ValueIterator :: struct {
  index: int,
  data: ValueSlice,
}

VALUE_INFO := runtime.type_info_base(type_info_of(typeid_of(Value))).variant.(runtime.Type_Info_Union)

iterate_values :: proc(it: ^ValueIterator) -> (val: Value, idx: int, cond: bool) {
  if cond = it.index < len(it.data.slice); cond {
    val = ---
    
    // set value
    type    := VALUE_INFO.variants[it.data.type]
    val_ptr := rawptr(uintptr(&it.data.slice[0]) + uintptr(type.size * it.index))
    intrinsics.mem_copy(&val, val_ptr, type.size)
    
    // set union tag
    tag_ptr := transmute(^u8)(uintptr(&val) + VALUE_INFO.tag_offset)
    tag_ptr^ = it.data.type
    
    // continue
    idx = it.index
    it.index += 1
  }
  return
}

Globals :: struct {
  state:  []StateVal,
  symbol: []Token,
  lexeme: []Token,
}

slice_to_val :: proc(s: $T/[]$E) -> Value {
  id := typeid_of(E)
  for variant, i in VALUE_INFO.variants {
    if variant.id == id {
      return ValueSlice{ u8(i), transmute([]void)s }
    }
  }
  return ---
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

    for sym in 0..<len(g.symbols) {
      symbol := Symbol(sym)
      if !(symbol in table[i]) do continue

      if k, ok := lookup[table[i][symbol]]; ok {
        clone := make([]Token, len(lah[k].symbol) + 1)
        copy(clone, lah[k].symbol)
        clone[len(clone) - 1] = { g.symbols[sym], g.enum_names[sym] }
        lah[k].symbol = clone
        continue
      }

      j := len(lah)
      lookup[table[i][symbol]] = j
      append(&lah, LookaheadVal { make_single(Token{ g.symbols[sym], g.enum_names[sym] }), nil, nil, nil })

      switch v in table[i][symbol] {
        case Reduce:
          if v == Reduce(START) {
            lah[j].accept = make_single(void{})
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

get_child :: proc(val: Value, s: string) -> (Value, bool) {
  #partial switch v in val {
    case LookaheadVal:
      switch s {
        case "symbol":
          return slice_to_val(v.symbol), true
        case "accept":
          return slice_to_val(v.accept), true
        case "shift":
          return slice_to_val(v.shift), true
        case "reduce":
          return slice_to_val(v.reduce), true
      }
    case ReduceVal:
      switch s {
        case "lhs":
          return v.lhs, true
        case "rhs":
          return slice_to_val(v.rhs), true
      }
    case StateVal:
      switch s {
        case "index":
          return v.index, true
        case "lookahead":
          return slice_to_val(v.lookahead), true
      }
    case Token:
      switch s {
        case "name":
          return v.name, true
        case "enum":
          return v.enum_value, true
      }
    case ValueSlice:
      switch s {
        case "length":
          return len(v.slice), true
      }
  }
  return ---, false
}

get_value :: proc(var: Var, stack: []StackElement) -> (value: Value, ok: bool) {
  for i := len(stack) - 1; i >= 0; i -= 1 {
    if var[0] != stack[i].var do continue
    
    value = stack[i].value
    for s in var[1:] {
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
  }
  return false
}

StackElement :: struct {
  var: string,
  value: Value,
}

eval :: proc(directives: []Directive, g: Grammar, table: Table) -> (s: string, ok: bool) {
  globals := make_globals(g, table)

  stack := make([dynamic]StackElement)
  append(&stack, StackElement{ "state",  slice_to_val(globals.state)  })
  append(&stack, StackElement{ "symbol", slice_to_val(globals.symbol) })
  append(&stack, StackElement{ "lexeme", slice_to_val(globals.lexeme) })

  sb := strings.builder_make_none()

  dirs := directives
  _eval(&sb, &stack, &dirs, false) or_return
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
          print_value(sb, val) or_return
          fmt.sbprint(sb, varlit.lit)
        }
      case Start:
        slice := (get_value(v.var, stack[:]) or_return).(ValueSlice) or_return
        it := ValueIterator{ 0, slice }
        for val, idx in iterate_values(&it) {
          append(stack, StackElement{ v.name, val })
          dirs := directives^;
          _eval(sb, stack, &dirs, idx == len(slice.slice) - 1) or_return
          pop(stack)
        }
        _skip(directives) or_return
      case End:
        return true
    }
  }
  return true
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
          if end == -1 do return ---, false

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

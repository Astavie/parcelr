package codegen

import "core:slice"
import "core:strconv"
import "core:strings"
import "core:fmt"

import "../grammar"

Symbol :: grammar.SymbolDefinition
void   :: struct{}

LookaheadVal :: struct {
  symbol: []Symbol,
  accept: []void,
  shift:  []int,
  reduce: []ReduceVal,
}

ReduceVal :: struct {
  lhs: Symbol,
  rhs: []Symbol,
  code: string,
}

StateVal :: struct {
  index: int,
  lookahead: []LookaheadVal,
}

Value :: union #no_nil { void, int, string, LookaheadVal, ReduceVal, StateVal, Symbol, []void, []int, []string, []LookaheadVal, []ReduceVal, []StateVal, []Symbol }

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
        case "code":
          return v.code, true
      }
    case StateVal:
      switch s {
        case "index":
          return v.index, true
        case "lookahead":
          return slice.clone(v.lookahead), true
      }
    case Symbol:
      switch s {
        case "name":
          return v.name, true
        case "enum":
          return v.enum_name, true
        case "type":
          return v.type, true
      }
    case []void:
      switch s {
        case "length":
          return len(v), true
      }
    case []int:
      // get element count
      if s[0] == '"' && s[len(s) - 1] == '"' {
        i := strconv.parse_int(s[1:len(s) - 1], 10) or_return
        return slice.count(v, i), true
      }
    case []string:
      // get element count
      if s[0] == '"' && s[len(s) - 1] == '"' {
        return slice.count(v, s[1:len(s) - 1]), true
      }
  }

  #partial switch v in val {
    case []string, []int, []LookaheadVal, []ReduceVal, []StateVal, []Symbol:
      it, _ := as_slice(val, false)
      switch s {
        case "length":
          return it.len, true
        case:
          // get slice index
          if i, ok := strconv.parse_int(s, 10); ok {
            if i >= 0 && i < it.len do for elem, idx in iterate_values(&it) {
              if i == idx do return elem, true
            }
            return []void{}, true
          }

          // get children of elements
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
      delete_value_slice(v.reduce)
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
    case []Symbol:
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
    case Symbol:
      return cast_slice(s, Symbol)
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
    case []Symbol:
      return iterate(v, &val.indx)
    case int:
      if val.indx > 0 || v == 0 do return ---, ---, false
      val.indx += 1
      return v, 0, true
    case string:
      if val.indx > 0 || v == "" do return ---, ---, false
      val.indx += 1
      return v, 0, true
    case:
      if val.indx > 0 do return ---, ---, false
      val.indx += 1
      return v, 0, true
  }
}

as_slice :: proc(val: Value, force: bool) -> (ValueIterator, bool) {
  #partial switch v in val {
    case []void, []int, []string, []LookaheadVal, []ReduceVal, []StateVal, []Symbol:
      p := val
      return { len((^[]void)(&p)^), 0, v }, true
    case:
      return { 1, 0, val }, force
  }
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

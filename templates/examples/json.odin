package parser

import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"

Entry :: struct {
  key: string,
  value: Value,
}

Object :: map[string]Value
Array :: []Value
Null :: struct{}
Value :: union #no_nil { Object, Array, string, int, bool, Null }

Values :: [dynamic]Value

Symbol :: enum { EOF, ERR, json, value, object, array, string, number, _9, _10, _11, _12, _13, members, member, _16, _17, _18, _19, values, }

SymbolValue :: struct { symbol: Symbol, value: rawptr }

HANDLES_ERRORS := map[int]struct{}{ }

symbol_name :: proc(symbol: Symbol) -> string {
  switch symbol {
    case .EOF: return "$"
    case .ERR: return "error"
    case .json: return "json"
    case .value: return "value"
    case .object: return "object"
    case .array: return "array"
    case .string: return "string"
    case .number: return "number"
    case ._9: return "true"
    case ._10: return "false"
    case ._11: return "null"
    case ._12: return "{"
    case ._13: return "}"
    case .members: return "members"
    case .member: return "member"
    case ._16: return ","
    case ._17: return ":"
    case ._18: return "["
    case ._19: return "]"
    case .values: return "values"
  }
  return ""
}

PARCELR_DEBUG :: true

when PARCELR_DEBUG {
  main :: proc() {
    symbols := make([dynamic]SymbolValue)
    defer delete(symbols)

    if len(os.args) >= 2 {
      for s in os.args[1:] {
        strs := strings.split(s, " ")
        defer delete(strs)

        for w in strs {
          switch w {
            case "error": append(&symbols, SymbolValue{ .ERR, nil })
            case "string": append(&symbols, SymbolValue{ .string, nil })
            case "number": append(&symbols, SymbolValue{ .number, nil })
            case "true": append(&symbols, SymbolValue{ ._9, nil })
            case "false": append(&symbols, SymbolValue{ ._10, nil })
            case "null": append(&symbols, SymbolValue{ ._11, nil })
            case "{": append(&symbols, SymbolValue{ ._12, nil })
            case "}": append(&symbols, SymbolValue{ ._13, nil })
            case ",": append(&symbols, SymbolValue{ ._16, nil })
            case ":": append(&symbols, SymbolValue{ ._17, nil })
            case "[": append(&symbols, SymbolValue{ ._18, nil })
            case "]": append(&symbols, SymbolValue{ ._19, nil })
            case: append(&symbols, SymbolValue{ .ERR, nil })
          }
        }
      }
    }

    fmt.println()
    for sym in symbols {
      fmt.printf("%s ", symbol_name(sym.symbol))
    }
    fmt.println()
    fmt.println()
    fmt.println(parse(symbols[:]))
    fmt.println()
  }
}

parse :: proc(lexemes: []SymbolValue) -> (Value,bool) {
  stack := slice.clone_to_dynamic(lexemes)
  slice.reverse(stack[:])

  State :: struct { symbol: Symbol, value: rawptr, state: int }

  shifted: #soa[dynamic]State
  state := 0
  errors := 0

  defer delete(stack)
  defer delete_soa(shifted)
  
  deref :: proc(ptr: rawptr, $T: typeid) -> T {
    defer free(ptr)
    return (^T)(ptr)^
  }

  peek :: proc(a: []SymbolValue) -> Symbol {
    i := len(a) - 1
    if i >= 0 do return a[i].symbol
    return .EOF
  }

  shift :: proc(stack: ^[dynamic]SymbolValue, shifted: ^#soa[dynamic]State, state: ^int, new_state: int, errors: ^int) {
    val := pop_safe(stack) or_else SymbolValue{ .EOF, nil }
    if val.symbol == .ERR do errors^ += 1
    append_soa(shifted, State { val.symbol, val.value, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]SymbolValue, shifted: ^#soa[dynamic]State, state: ^int, errors: ^int, f: $T/proc(children: [$N]rawptr) -> SymbolValue) {
    vals: [N]rawptr = ---
    when N > 0 {
      _, values, _ := soa_unzip(shifted^[:])
      copy_slice(vals[:], values[len(values) - N:])
      state^ = shifted[len(shifted) - N].state
      resize_soa(shifted, len(shifted) - N)
    }
    append(stack, f(vals))
  }

  when PARCELR_DEBUG {
    dump :: proc(stack: [dynamic]SymbolValue, shifted: #soa[dynamic]State, state: int, size: int) {
      for s, i in shifted {
        if i >= len(shifted) - size {
          fmt.printf(" \u001b[46m\u001b[90m%i\u001b[30m %s", s.state, symbol_name(s.symbol))
        } else {
          fmt.printf(" \u001b[90m%i\u001b[39m %s", s.state, symbol_name(s.symbol))
        }
      }
      fmt.printf("\u001b[0m \u001b[100m%i", state)
      for i := len(stack) - 1; i >= 0; i -= 1 {
        fmt.printf(" %s\u001b[0m", symbol_name(stack[i].symbol))
      }
      fmt.printf(" %s\u001b[0m", symbol_name(.EOF))
      fmt.println()
    }
  }

  for {
    symbol := peek(stack[:])
    switch state {
      case 0:
        #partial switch symbol {
          case .json:
            shift(&stack, &shifted, &state, 1, &errors)
            continue
          case .value:
            shift(&stack, &shifted, &state, 2, &errors)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3, &errors)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5, &errors)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6, &errors)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 7, &errors)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 8, &errors)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 9, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 1:
        #partial switch symbol {
          case .EOF:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 2)
              fmt.println()
            }
            return deref(shifted[0].value, Value), true
        }
      case 2:
        #partial switch symbol {
          case .EOF:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce json -> value .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value; _0 := deref(children[0], Value)
                this = _0
                ret = new_clone(this); return { .json, ret }
              })
            continue
        }
      case 3:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> object .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value; _0 := deref(children[0], Object)
                this = _0
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 4:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> array .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value; _0 := deref(children[0], Array)
                this = _0
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 5:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> string .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value
                this = "string"
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 6:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> number .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value
                this = 69
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 7:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> true .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value
                this = true
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 8:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> false .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value
                this = false
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 9:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce value -> null .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Value
                this = Null{}
                ret = new_clone(this); return { .value, ret }
              })
            continue
        }
      case 10:
        #partial switch symbol {
          case ._19:
            shift(&stack, &shifted, &state, 12, &errors)
            continue
          case .values:
            shift(&stack, &shifted, &state, 13, &errors)
            continue
          case .value:
            shift(&stack, &shifted, &state, 14, &errors)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3, &errors)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5, &errors)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6, &errors)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 7, &errors)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 8, &errors)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 9, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 11:
        #partial switch symbol {
          case ._13:
            shift(&stack, &shifted, &state, 15, &errors)
            continue
          case .members:
            shift(&stack, &shifted, &state, 16, &errors)
            continue
          case .member:
            shift(&stack, &shifted, &state, 17, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 18, &errors)
            continue
        }
      case 12:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 2)
              fmt.println("    reduce array -> [ ] .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Array
                this = Array{}
                ret = new_clone(this); return { .array, ret }
              })
            continue
        }
      case 13:
        #partial switch symbol {
          case ._19:
            shift(&stack, &shifted, &state, 19, &errors)
            continue
          case ._16:
            shift(&stack, &shifted, &state, 20, &errors)
            continue
        }
      case 14:
        #partial switch symbol {
          case ._16, ._19:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce values -> value .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Value)
                this = make(Values); append(&this, _0)
                ret = new_clone(this); return { .values, ret }
              })
            continue
        }
      case 15:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 2)
              fmt.println("    reduce object -> { } .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Object
                this = Object{}
                ret = new_clone(this); return { .object, ret }
              })
            continue
        }
      case 16:
        #partial switch symbol {
          case ._13:
            shift(&stack, &shifted, &state, 21, &errors)
            continue
          case ._16:
            shift(&stack, &shifted, &state, 22, &errors)
            continue
        }
      case 17:
        #partial switch symbol {
          case ._13, ._16:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 1)
              fmt.println("    reduce members -> member .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Entry)
                this = make(Object); this[_0.key] = _0.value
                ret = new_clone(this); return { .members, ret }
              })
            continue
        }
      case 18:
        #partial switch symbol {
          case ._17:
            shift(&stack, &shifted, &state, 23, &errors)
            continue
        }
      case 19:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 3)
              fmt.println("    reduce array -> [ values ] .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Array; _1 := deref(children[1], Values)
                this = _1[:]
                ret = new_clone(this); return { .array, ret }
              })
            continue
        }
      case 20:
        #partial switch symbol {
          case .value:
            shift(&stack, &shifted, &state, 24, &errors)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3, &errors)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5, &errors)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6, &errors)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 7, &errors)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 8, &errors)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 9, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 21:
        #partial switch symbol {
          case .EOF, ._16, ._19, ._13:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 3)
              fmt.println("    reduce object -> { members } .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _1 := deref(children[1], Object)
                this = _1
                ret = new_clone(this); return { .object, ret }
              })
            continue
        }
      case 22:
        #partial switch symbol {
          case .member:
            shift(&stack, &shifted, &state, 25, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 18, &errors)
            continue
        }
      case 23:
        #partial switch symbol {
          case .value:
            shift(&stack, &shifted, &state, 26, &errors)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3, &errors)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5, &errors)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6, &errors)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 7, &errors)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 8, &errors)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 9, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 24:
        #partial switch symbol {
          case ._16, ._19:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 3)
              fmt.println("    reduce values -> values , value .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Values); _2 := deref(children[2], Value)
                this = _0;           append(&this, _2)
                ret = new_clone(this); return { .values, ret }
              })
            continue
        }
      case 25:
        #partial switch symbol {
          case ._13, ._16:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 3)
              fmt.println("    reduce members -> members , member .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Object); _2 := deref(children[2], Entry)
                this = _0;           this[_2.key] = _2.value
                ret = new_clone(this); return { .members, ret }
              })
            continue
        }
      case 26:
        #partial switch symbol {
          case ._13, ._16:
            when PARCELR_DEBUG {
              dump(stack, shifted, state, 3)
              fmt.println("    reduce member -> string : value .")
            }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Entry; _2 := deref(children[2], Value)
                this = Entry{ "string", _2 }
                ret = new_clone(this); return { .member, ret }
              })
            continue
        }
    }

    if errors > 0 {
      if state in HANDLES_ERRORS {
        append(&stack, SymbolValue{ .ERR, nil })
        continue
      }

      if len(stack) == 0 do return ---, false
      pop(&stack)
      continue
    }

    if symbol != .ERR {
      append(&stack, SymbolValue{ .ERR, nil })
      continue
    }

    if len(stack) == 0 do return ---, false
    state = shifted[len(shifted) - 1].state
    resize_soa(&shifted, len(shifted) - 1)
    continue
  }
}

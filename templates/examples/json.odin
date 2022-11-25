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

Symbol :: enum { EOF, ERR, json, value, object, array, string, number, _9, _10, _11, _12, _13, members, premembers, member, _17, _18, _19, _20, values, prevalues, }

SymbolValue :: struct { symbol: Symbol, value: rawptr }

HANDLES_ERRORS := map[int]struct{}{ 10 = {}, 11 = {}, 14 = {}, 19 = {}, 26 = {}, 27 = {}, 31 = {}, 32 = {}, 36 = {}, 37 = {}, 39 = {}, 40 = {}, }

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
    case .premembers: return "premembers"
    case .member: return "member"
    case ._17: return ","
    case ._18: return ":"
    case ._19: return "["
    case ._20: return "]"
    case .values: return "values"
    case .prevalues: return "prevalues"
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
            case ",": append(&symbols, SymbolValue{ ._17, nil })
            case ":": append(&symbols, SymbolValue{ ._18, nil })
            case "[": append(&symbols, SymbolValue{ ._19, nil })
            case "]": append(&symbols, SymbolValue{ ._20, nil })
            case: append(&symbols, SymbolValue{ .ERR, nil })
          }
        }
      }
    }

    fmt.println(parse(symbols[:]))
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

  for {
    when PARCELR_DEBUG {
      for s in shifted {
        fmt.printf("\u001b[90m%i\u001b[0m %s ", s.state, symbol_name(s.symbol))
      }
      fmt.printf("\u001b[100m%i", state)
      for i := len(stack) - 1; i >= 0; i -= 1 {
        fmt.printf(" %s\u001b[0m", symbol_name(stack[i].symbol))
      }
      fmt.printf(" %s\u001b[0m", symbol_name(.EOF))
      fmt.println()
    }
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
          case ._19:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 1:
        #partial switch symbol {
          case .EOF:
            return deref(shifted[0].value, Value), true
        }
      case 2:
        #partial switch symbol {
          case .EOF:
            when PARCELR_DEBUG { fmt.println("reduce json -> value .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> object .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> array .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> string .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> number .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> true .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> false .") }
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
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> null .") }
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
          case ._20:
            shift(&stack, &shifted, &state, 12, &errors)
            continue
          case .values:
            shift(&stack, &shifted, &state, 13, &errors)
            continue
          case .prevalues:
            shift(&stack, &shifted, &state, 14, &errors)
            continue
          case .value:
            shift(&stack, &shifted, &state, 15, &errors)
            continue
          case .ERR:
            shift(&stack, &shifted, &state, 16, &errors)
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
          case ._19:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 11:
        #partial switch symbol {
          case ._13:
            shift(&stack, &shifted, &state, 17, &errors)
            continue
          case .members:
            shift(&stack, &shifted, &state, 18, &errors)
            continue
          case .premembers:
            shift(&stack, &shifted, &state, 19, &errors)
            continue
          case .member:
            shift(&stack, &shifted, &state, 20, &errors)
            continue
          case .ERR:
            shift(&stack, &shifted, &state, 21, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 22, &errors)
            continue
        }
      case 12:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce array -> [ ] .") }
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
          case ._20:
            shift(&stack, &shifted, &state, 23, &errors)
            continue
        }
      case 14:
        #partial switch symbol {
          case .ERR:
            shift(&stack, &shifted, &state, 24, &errors)
            continue
          case .value:
            shift(&stack, &shifted, &state, 25, &errors)
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
          case ._19:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 15:
        #partial switch symbol {
          case ._20:
            when PARCELR_DEBUG { fmt.println("reduce values -> value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Value)
                this = make(Values); append(&this, _0)
                ret = new_clone(this); return { .values, ret }
              })
            continue
          case ._17:
            shift(&stack, &shifted, &state, 26, &errors)
            continue
        }
      case 16:
        #partial switch symbol {
          case ._17:
            shift(&stack, &shifted, &state, 27, &errors)
            continue
        }
      case 17:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce object -> { } .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Object
                this = Object{}
                ret = new_clone(this); return { .object, ret }
              })
            continue
        }
      case 18:
        #partial switch symbol {
          case ._13:
            shift(&stack, &shifted, &state, 28, &errors)
            continue
        }
      case 19:
        #partial switch symbol {
          case .ERR:
            shift(&stack, &shifted, &state, 29, &errors)
            continue
          case .member:
            shift(&stack, &shifted, &state, 30, &errors)
            continue
          case .string:
            shift(&stack, &shifted, &state, 22, &errors)
            continue
        }
      case 20:
        #partial switch symbol {
          case ._13:
            when PARCELR_DEBUG { fmt.println("reduce members -> member .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Entry)
                this = make(Object); this[_0.key] = _0.value
                ret = new_clone(this); return { .members, ret }
              })
            continue
          case ._17:
            shift(&stack, &shifted, &state, 31, &errors)
            continue
        }
      case 21:
        #partial switch symbol {
          case ._17:
            shift(&stack, &shifted, &state, 32, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 33, &errors)
            continue
        }
      case 22:
        #partial switch symbol {
          case ._18:
            shift(&stack, &shifted, &state, 34, &errors)
            continue
        }
      case 23:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce array -> [ values ] .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Array; _1 := deref(children[1], Values)
                this = _1[:]
                ret = new_clone(this); return { .array, ret }
              })
            continue
        }
      case 24:
        #partial switch symbol {
          case ._20:
            shift(&stack, &shifted, &state, 35, &errors)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 36, &errors)
            continue
        }
      case 25:
        #partial switch symbol {
          case ._20:
            when PARCELR_DEBUG { fmt.println("reduce values -> prevalues value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Values); _1 := deref(children[1], Value)
                this = _0;           append(&this, _1)
                ret = new_clone(this); return { .values, ret }
              })
            continue
          case ._17:
            shift(&stack, &shifted, &state, 37, &errors)
            continue
        }
      case 26:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> value , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Value)
                this = make(Values); append(&this, _0)
                ret = new_clone(this); return { .prevalues, ret }
              })
            continue
        }
      case 27:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Values
                this = make(Values)
                ret = new_clone(this); return { .prevalues, ret }
              })
            continue
        }
      case 28:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce object -> { members } .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _1 := deref(children[1], Object)
                this = _1
                ret = new_clone(this); return { .object, ret }
              })
            continue
        }
      case 29:
        #partial switch symbol {
          case ._13:
            shift(&stack, &shifted, &state, 38, &errors)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 39, &errors)
            continue
          case ._18:
            shift(&stack, &shifted, &state, 33, &errors)
            continue
        }
      case 30:
        #partial switch symbol {
          case ._13:
            when PARCELR_DEBUG { fmt.println("reduce members -> premembers member .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Object); _1 := deref(children[1], Entry)
                this = _0;           this[_1.key] = _1.value
                ret = new_clone(this); return { .members, ret }
              })
            continue
          case ._17:
            shift(&stack, &shifted, &state, 40, &errors)
            continue
        }
      case 31:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> member , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Entry)
                this = make(Object); this[_0.key] = _0.value
                ret = new_clone(this); return { .premembers, ret }
              })
            continue
        }
      case 32:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]rawptr) -> SymbolValue {
                ret: rawptr; this: Object
                this = make(Object)
                ret = new_clone(this); return { .premembers, ret }
              })
            continue
        }
      case 33:
        #partial switch symbol {
          case .value:
            shift(&stack, &shifted, &state, 41, &errors)
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
          case ._19:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 34:
        #partial switch symbol {
          case .value:
            shift(&stack, &shifted, &state, 42, &errors)
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
          case ._19:
            shift(&stack, &shifted, &state, 10, &errors)
            continue
          case ._12:
            shift(&stack, &shifted, &state, 11, &errors)
            continue
        }
      case 35:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce array -> [ prevalues error ] .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [4]rawptr) -> SymbolValue {
                ret: rawptr; this: Array; _1 := deref(children[1], Values)
                this = _1[:]
                ret = new_clone(this); return { .array, ret }
              })
            continue
        }
      case 36:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> prevalues error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Values)
                this = _0
                ret = new_clone(this); return { .prevalues, ret }
              })
            continue
        }
      case 37:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> prevalues value , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Values; _0 := deref(children[0], Values); _1 := deref(children[1], Value)
                this = _0;           append(&this, _1)
                ret = new_clone(this); return { .prevalues, ret }
              })
            continue
        }
      case 38:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce object -> { premembers error } .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [4]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _1 := deref(children[1], Object)
                this = _1
                ret = new_clone(this); return { .object, ret }
              })
            continue
        }
      case 39:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> premembers error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Object)
                this = _0
                ret = new_clone(this); return { .premembers, ret }
              })
            continue
        }
      case 40:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> premembers member , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Object; _0 := deref(children[0], Object); _1 := deref(children[1], Entry)
                this = _0;           this[_1.key] = _1.value
                ret = new_clone(this); return { .premembers, ret }
              })
            continue
        }
      case 41:
        #partial switch symbol {
          case ._13, ._17:
            when PARCELR_DEBUG { fmt.println("reduce member -> error : value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]rawptr) -> SymbolValue {
                ret: rawptr; this: Entry; _2 := deref(children[2], Value)
                this = Entry{ {}      , _2 }
                ret = new_clone(this); return { .member, ret }
              })
            continue
        }
      case 42:
        #partial switch symbol {
          case ._13, ._17:
            when PARCELR_DEBUG { fmt.println("reduce member -> string : value .") }
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

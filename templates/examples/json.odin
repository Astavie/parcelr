package parser

import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"

Symbol :: enum { EOF, ERR, json, value, object, array, string, number, _9, _10, _11, _12, _13, members, premembers, member, _17, _18, _19, _20, values, prevalues, }

Value :: struct { symbol: Symbol, value: any }

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
    symbols := make([dynamic]Value)
    defer delete(symbols)

    if len(os.args) >= 2 {
      for s in os.args[1:] {
        strs := strings.split(s, " ")
        defer delete(strs)

        for w in strs {
          switch w {
            case "error": append(&symbols, Value{ .ERR, new_any(w) })
            case "string": append(&symbols, Value{ .string, new_any(w) })
            case "number": append(&symbols, Value{ .number, new_any(w) })
            case "true": append(&symbols, Value{ ._9, new_any(w) })
            case "false": append(&symbols, Value{ ._10, new_any(w) })
            case "null": append(&symbols, Value{ ._11, new_any(w) })
            case "{": append(&symbols, Value{ ._12, new_any(w) })
            case "}": append(&symbols, Value{ ._13, new_any(w) })
            case ",": append(&symbols, Value{ ._17, new_any(w) })
            case ":": append(&symbols, Value{ ._18, new_any(w) })
            case "[": append(&symbols, Value{ ._19, new_any(w) })
            case "]": append(&symbols, Value{ ._20, new_any(w) })
            case: append(&symbols, Value{ .ERR, nil })
          }
        }
      }
    }

    parsed := parse(symbols[:])
    fmt.println(symbol_name(parsed.symbol), parsed.value)
  }
}

Pair :: struct($Key, $Value: typeid) {
  key: Key,
  value: Value,
}
as :: proc(ptr: any, $T: typeid) -> ^T {
  return (^T)(ptr.data)
}
deref :: proc(ptr: any, $T: typeid) -> T {
  defer free(ptr.data)
  return as(ptr, T)^
}
new_any :: proc(data: $T) -> any {
  return any{new_clone(data), typeid_of(T)}
}

parse :: proc(lexemes: []Value) -> Value {
  stack := slice.clone_to_dynamic(lexemes)
  slice.reverse(stack[:])

  State :: struct { symbol: Symbol, value: any, state: int }

  shifted: #soa[dynamic]State
  state := 0
  errors := 0

  defer delete(stack)
  defer delete_soa(shifted)

  peek :: proc(a: []Value) -> Symbol {
    i := len(a) - 1
    if i >= 0 do return a[i].symbol
    return .EOF
  }

  shift :: proc(stack: ^[dynamic]Value, shifted: ^#soa[dynamic]State, state: ^int, new_state: int, errors: ^int) {
    val := pop_safe(stack) or_else Value{ .EOF, nil }
    if val.symbol == .ERR do errors^ += 1
    append_soa(shifted, State { val.symbol, val.value, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]Value, shifted: ^#soa[dynamic]State, state: ^int, errors: ^int, f: $T/proc(children: [$N]any) -> Value) {
    vals: [N]any = ---
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
            return Value{ shifted[0].symbol, shifted[0].value }
        }
      case 2:
        #partial switch symbol {
          case .EOF:
            when PARCELR_DEBUG { fmt.println("reduce json -> value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = children[0]
                return { .json, this }
              })
            continue
        }
      case 3:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> object .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = children[0]
                return { .value, this }
              })
            continue
        }
      case 4:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> array .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = children[0]
                return { .value, this }
              })
            continue
        }
      case 5:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> string .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = new_any("string")
                return { .value, this }
              })
            continue
        }
      case 6:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> number .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = new_any(69)
                return { .value, this }
              })
            continue
        }
      case 7:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> true .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = new_any(true)
                return { .value, this }
              })
            continue
        }
      case 8:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> false .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = new_any(false)
                return { .value, this }
              })
            continue
        }
      case 9:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce value -> null .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [1]any) -> Value {
                this: any
                this = nil
                return { .value, this }
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
              proc (children: [2]any) -> Value {
                this: any
                this = new_any([]any{})
                return { .array, this }
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
              proc (children: [1]any) -> Value {
                this: any
                this = new_any(make([dynamic]any)); append(as(this, [dynamic]any), children[0])
                return { .values, this }
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
              proc (children: [2]any) -> Value {
                this: any
                this = new_any(map[string]any{})
                return { .object, this }
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
              proc (children: [1]any) -> Value {
                this: any
                this = new_any(make(map[string]any)); pair := deref(children[0], Pair(string, any)); as(this, map[string]any)[pair.key] = pair.value
                return { .members, this }
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
              proc (children: [3]any) -> Value {
                this: any
                this = new_any(deref(children[1], [dynamic]any)[:])
                return { .array, this }
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
          case ._17:
            shift(&stack, &shifted, &state, 37, &errors)
            continue
          case ._20:
            when PARCELR_DEBUG { fmt.println("reduce values -> prevalues value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = children[0]; append(as(this, [dynamic]any), children[1])
                return { .values, this }
              })
            continue
        }
      case 26:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> value , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = new_any(make([dynamic]any)); append(as(this, [dynamic]any), children[0])
                return { .prevalues, this }
              })
            continue
        }
      case 27:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = new_any(make([dynamic]any))
                return { .prevalues, this }
              })
            continue
        }
      case 28:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce object -> { members } .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = children[1]
                return { .object, this }
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
          case ._17:
            shift(&stack, &shifted, &state, 40, &errors)
            continue
          case ._13:
            when PARCELR_DEBUG { fmt.println("reduce members -> premembers member .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = children[0]; pair := deref(children[1], Pair(string, any)); as(this, map[string]any)[pair.key] = pair.value
                return { .members, this }
              })
            continue
        }
      case 31:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> member , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = new_any(make(map[string]any)); pair := deref(children[0], Pair(string, any)); as(this, map[string]any)[pair.key] = pair.value
                return { .premembers, this }
              })
            continue
        }
      case 32:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [2]any) -> Value {
                this: any
                this = new_any(make(map[string]any))
                return { .premembers, this }
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
              proc (children: [4]any) -> Value {
                this: any
                this = new_any(deref(children[1], [dynamic]any)[:])
                return { .array, this }
              })
            continue
        }
      case 36:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> prevalues error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = children[0]
                return { .prevalues, this }
              })
            continue
        }
      case 37:
        #partial switch symbol {
          case .ERR, .string, .number, ._9, ._10, ._11, ._12, ._19:
            when PARCELR_DEBUG { fmt.println("reduce prevalues -> prevalues value , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = children[0]; append(as(this, [dynamic]any), children[1])
                return { .prevalues, this }
              })
            continue
        }
      case 38:
        #partial switch symbol {
          case .EOF, ._17, ._20, ._13:
            when PARCELR_DEBUG { fmt.println("reduce object -> { premembers error } .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [4]any) -> Value {
                this: any
                this = children[1]
                return { .object, this }
              })
            continue
        }
      case 39:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> premembers error , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = children[0]
                return { .premembers, this }
              })
            continue
        }
      case 40:
        #partial switch symbol {
          case .ERR, .string:
            when PARCELR_DEBUG { fmt.println("reduce premembers -> premembers member , .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = children[0]; pair := deref(children[1], Pair(string, any)); as(this, map[string]any)[pair.key] = pair.value
                return { .premembers, this }
              })
            continue
        }
      case 41:
        #partial switch symbol {
          case ._13, ._17:
            when PARCELR_DEBUG { fmt.println("reduce member -> error : value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = new_any(Pair(string, any){ {}, children[2] })
                return { .member, this }
              })
            continue
        }
      case 42:
        #partial switch symbol {
          case ._13, ._17:
            when PARCELR_DEBUG { fmt.println("reduce member -> string : value .") }
            reduce(&stack, &shifted, &state, &errors,
              proc (children: [3]any) -> Value {
                this: any
                this = new_any(Pair(string, any){ deref(children[0], string), children[2] })
                return { .member, this }
              })
            continue
        }
    }

    if errors > 0 {
      if state in HANDLES_ERRORS {
        append(&stack, Value{ .ERR, nil })
        continue
      }
      
      if len(stack) == 0 do return Value{ .ERR, nil }
      pop(&stack)
      continue
    }
    
    if symbol != .ERR {
      append(&stack, Value{ .ERR, nil })
      continue
    }
    
    if len(shifted) == 0 do return Value{ .ERR, nil }
    state = shifted[len(shifted) - 1].state
    resize_soa(&shifted, len(shifted) - 1)
    continue
  }
}

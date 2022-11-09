package parser

import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"

Symbol :: enum { EOF, json, value, object, array, string, number, _8, _9, _10, _11, _12, members, member, _15, _16, _17, _18, values }

symbol_name :: proc(symbol: Symbol) -> string {
  switch symbol {
    case .EOF: return "EOF"
    case .json: return "json"
    case .value: return "value"
    case .object: return "object"
    case .array: return "array"
    case .string: return "string"
    case .number: return "number"
    case ._8: return "true"
    case ._9: return "false"
    case ._10: return "null"
    case ._11: return "{"
    case ._12: return "}"
    case .members: return "members"
    case .member: return "member"
    case ._15: return ","
    case ._16: return ":"
    case ._17: return "["
    case ._18: return "]"
    case .values: return "values"
  }
  return ""
}

PARCELR_DEBUG :: true

when PARCELR_DEBUG {
  main :: proc() {
    symbols := make([dynamic]Symbol)
    if len(os.args) >= 2 {
      for s in os.args[1:] {
        for w in strings.split(s, " ") {
          switch w {
            case "string": append(&symbols, Symbol.string)
            case "number": append(&symbols, Symbol.number)
            case "true": append(&symbols, Symbol._8)
            case "false": append(&symbols, Symbol._9)
            case "null": append(&symbols, Symbol._10)
            case "{": append(&symbols, Symbol._11)
            case "}": append(&symbols, Symbol._12)
            case ",": append(&symbols, Symbol._15)
            case ":": append(&symbols, Symbol._16)
            case "[": append(&symbols, Symbol._17)
            case "]": append(&symbols, Symbol._18)
            case:
              fmt.printf("Unknown token '%s'\n", w)
              return
          }
        }
      }
    }
    fmt.println(symbol_name(parse(symbols[:])))
  }
}

parse :: proc(lexemes: []Symbol) -> Symbol {
  stack := slice.clone_to_dynamic(lexemes)
  slice.reverse(stack[:])

  State :: struct { symbol: Symbol, state: int }

  shifted := make([dynamic]State)
  state := 0

  defer delete(stack)
  defer delete(shifted)

  peek :: proc(a: []Symbol) -> Symbol {
    i := len(a) - 1
    if i >= 0 do return a[i]
    return Symbol.EOF
  }

  shift :: proc(stack: ^[dynamic]Symbol, shifted: ^[dynamic]State, state: ^int, new_state: int) {
    append(shifted, State { pop_safe(stack) or_else Symbol.EOF, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]Symbol, shifted: ^[dynamic]State, state: ^int, f: $T/proc(symbols: [$N]Symbol) -> Symbol) {
    symbols : [N]Symbol = ---
    when N > 0 {
      state^ = shifted[len(shifted) - N].state
    }
    for i := N - 1; i >= 0; i -= 1 {
      symbols[i] = pop(shifted).symbol
    }
    append(stack, f(symbols))
  }

  for {
    when PARCELR_DEBUG {
      for s in shifted {
        fmt.printf("\u001b[90m%i\u001b[0m %s ", s.state, symbol_name(s.symbol))
      }
      fmt.printf("\u001b[100m%i", state)
      for i := len(stack) - 1; i >= 0; i -= 1 {
        fmt.printf(" %s\u001b[0m", symbol_name(stack[i]))
      }
      fmt.println(" $\u001b[0m")
    }
    symbol := peek(stack[:])
    switch state {
      case 0:
        #partial switch symbol {
          case .json:
            shift(&stack, &shifted, &state, 1)
            continue
          case .value:
            shift(&stack, &shifted, &state, 2)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6)
            continue
          case ._8:
            shift(&stack, &shifted, &state, 7)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 8)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 9)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 10)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            symbols :: [?]Symbol{ .json, .value, .object, .array, .string, .number, ._8, ._9, ._10, ._17, ._11 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 1:
        #partial switch symbol {
          case .EOF:
            return shifted[0].symbol
          case:
            symbols :: [?]Symbol{ .EOF }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 2:
        #partial switch symbol {
          case .EOF:
            when PARCELR_DEBUG { fmt.println("reduce json -> value .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.json })
            continue
          case:
            symbols :: [?]Symbol{ .EOF }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 3:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> object .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 4:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> array .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 5:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> string .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 6:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> number .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 7:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> true .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 8:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> false .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 9:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce value -> null .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.value })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 10:
        #partial switch symbol {
          case ._18:
            shift(&stack, &shifted, &state, 12)
            continue
          case .values:
            shift(&stack, &shifted, &state, 13)
            continue
          case .value:
            shift(&stack, &shifted, &state, 14)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6)
            continue
          case ._8:
            shift(&stack, &shifted, &state, 7)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 8)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 9)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 10)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            symbols :: [?]Symbol{ ._18, .values, .value, .object, .array, .string, .number, ._8, ._9, ._10, ._17, ._11 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 11:
        #partial switch symbol {
          case ._12:
            shift(&stack, &shifted, &state, 15)
            continue
          case .members:
            shift(&stack, &shifted, &state, 16)
            continue
          case .member:
            shift(&stack, &shifted, &state, 17)
            continue
          case .string:
            shift(&stack, &shifted, &state, 18)
            continue
          case:
            symbols :: [?]Symbol{ ._12, .members, .member, .string }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 12:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce array -> [ ] .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [2]Symbol) -> Symbol { return Symbol.array })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 13:
        #partial switch symbol {
          case ._18:
            shift(&stack, &shifted, &state, 19)
            continue
          case:
            symbols :: [?]Symbol{ ._18 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 14:
        #partial switch symbol {
          case ._18:
            when PARCELR_DEBUG { fmt.println("reduce values -> value .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.values })
            continue
          case ._15:
            shift(&stack, &shifted, &state, 20)
            continue
          case:
            symbols :: [?]Symbol{ ._18, ._15 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 15:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce object -> { } .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [2]Symbol) -> Symbol { return Symbol.object })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 16:
        #partial switch symbol {
          case ._12:
            shift(&stack, &shifted, &state, 21)
            continue
          case:
            symbols :: [?]Symbol{ ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 17:
        #partial switch symbol {
          case ._12:
            when PARCELR_DEBUG { fmt.println("reduce members -> member .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [1]Symbol) -> Symbol { return Symbol.members })
            continue
          case ._15:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            symbols :: [?]Symbol{ ._12, ._15 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 18:
        #partial switch symbol {
          case ._16:
            shift(&stack, &shifted, &state, 23)
            continue
          case:
            symbols :: [?]Symbol{ ._16 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 19:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce array -> [ values ] .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [3]Symbol) -> Symbol { return Symbol.array })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 20:
        #partial switch symbol {
          case .values:
            shift(&stack, &shifted, &state, 24)
            continue
          case .value:
            shift(&stack, &shifted, &state, 14)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6)
            continue
          case ._8:
            shift(&stack, &shifted, &state, 7)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 8)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 9)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 10)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            symbols :: [?]Symbol{ .values, .value, .object, .array, .string, .number, ._8, ._9, ._10, ._17, ._11 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 21:
        #partial switch symbol {
          case .EOF, ._15, ._18, ._12:
            when PARCELR_DEBUG { fmt.println("reduce object -> { members } .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [3]Symbol) -> Symbol { return Symbol.object })
            continue
          case:
            symbols :: [?]Symbol{ .EOF, ._15, ._18, ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 22:
        #partial switch symbol {
          case .members:
            shift(&stack, &shifted, &state, 25)
            continue
          case .member:
            shift(&stack, &shifted, &state, 17)
            continue
          case .string:
            shift(&stack, &shifted, &state, 18)
            continue
          case:
            symbols :: [?]Symbol{ .members, .member, .string }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 23:
        #partial switch symbol {
          case .value:
            shift(&stack, &shifted, &state, 26)
            continue
          case .object:
            shift(&stack, &shifted, &state, 3)
            continue
          case .array:
            shift(&stack, &shifted, &state, 4)
            continue
          case .string:
            shift(&stack, &shifted, &state, 5)
            continue
          case .number:
            shift(&stack, &shifted, &state, 6)
            continue
          case ._8:
            shift(&stack, &shifted, &state, 7)
            continue
          case ._9:
            shift(&stack, &shifted, &state, 8)
            continue
          case ._10:
            shift(&stack, &shifted, &state, 9)
            continue
          case ._17:
            shift(&stack, &shifted, &state, 10)
            continue
          case ._11:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            symbols :: [?]Symbol{ .value, .object, .array, .string, .number, ._8, ._9, ._10, ._17, ._11 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 24:
        #partial switch symbol {
          case ._18:
            when PARCELR_DEBUG { fmt.println("reduce values -> value , values .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [3]Symbol) -> Symbol { return Symbol.values })
            continue
          case:
            symbols :: [?]Symbol{ ._18 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 25:
        #partial switch symbol {
          case ._12:
            when PARCELR_DEBUG { fmt.println("reduce members -> member , members .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [3]Symbol) -> Symbol { return Symbol.members })
            continue
          case:
            symbols :: [?]Symbol{ ._12 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
      case 26:
        #partial switch symbol {
          case ._12, ._15:
            when PARCELR_DEBUG { fmt.println("reduce member -> string : value .") }
            reduce(&stack, &shifted, &state,
              proc (symbols: [3]Symbol) -> Symbol { return Symbol.member })
            continue
          case:
            symbols :: [?]Symbol{ ._12, ._15 }
            fmt.printf("Unexpected %v, expected %v\n", symbol, symbols)
            return nil
        }
    }
  }
}

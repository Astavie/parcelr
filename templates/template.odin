package parser

import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"

Symbol :: enum { EOF, ERR } //d
//l Symbol :: enum {
//symbol
  //w  ${symbol.enum},
//e
//w  }

Value :: struct { symbol: Symbol, value: any }

HANDLES_ERRORS := map[int]struct{}{} //d
//l HANDLES_ERRORS := map[int]struct{}{
//state
  //state.lookahead.symbol.enum.ERR
    //w  ${state.index} = {},
  //e
//e
//w  }

symbol_name :: proc(symbol: Symbol) -> string {
  switch symbol {
    case .EOF: return "EOF" //d
    case .ERR: return "ERR" //d
  //symbol
    //l case .${symbol.enum}: return "${symbol.name}"
  //e
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
          //lexeme
            //l case "${lexeme.name}": append(&symbols, Value{ .${lexeme.enum}, new_any(w) })
          //e
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
    //state
      //l case ${state.index}:
      case 0: //d
        #partial switch symbol {
        //state.lookahead lah
          //l case
          //lah.symbol
            //w  .${symbol.enum}
            //s ,
          //e
          //w :
          //lah.accept
            //l return Value{ shifted[0].symbol, shifted[0].value }
          //e
          //lah.shift
            //l shift(&stack, &shifted, &state, ${shift}, &errors)
            //l continue
          //e
          //lah.reduce
            //l when PARCELR_DEBUG { fmt.println("reduce ${reduce}") }
            //l reduce(&stack, &shifted, &state, &errors,
            //l   proc (children: [${reduce.rhs.length}]any) -> Value {
            //l     this: any
            //reduce.code
              //l   ${reduce.code}
            //e
            //l     return { .${reduce.lhs.enum}, this }
            //l   })
            //l continue
          //e
        //e
        }
    //e
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

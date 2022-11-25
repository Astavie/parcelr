package parser

import "core:slice"
import "core:fmt"
import "core:os"
import "core:strings"

//preamble
//l ${preamble}

//e
Symbol :: enum { EOF, ERR } //d
//l Symbol :: enum {
//symbol
  //w  ${symbol.enum},
//e
//w  }

SymbolValue :: struct { symbol: Symbol, value: rawptr }

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
    symbols := make([dynamic]SymbolValue)
    defer delete(symbols)

    if len(os.args) >= 2 {
      for s in os.args[1:] {
        strs := strings.split(s, " ")
        defer delete(strs)

        for w in strs {
          switch w {
          //lexeme
            //l case "${lexeme.name}": append(&symbols, SymbolValue{ .${lexeme.enum}, nil })
          //e
            case: append(&symbols, SymbolValue{ .ERR, nil })
          }
        }
      }
    }

    parsed := parse(symbols[:])
    fmt.println(symbol_name(parsed.symbol), parsed.value)
  }
}

parse :: proc(lexemes: []SymbolValue) -> SymbolValue {
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
            //l return SymbolValue{ shifted[0].symbol, shifted[0].value }
          //e
          //lah.shift
            //l shift(&stack, &shifted, &state, ${shift}, &errors)
            //l continue
          //e
          //lah.reduce
            //l when PARCELR_DEBUG { fmt.println("reduce ${reduce}") }
            //l reduce(&stack, &shifted, &state, &errors,
            //l   proc (children: [${reduce.rhs.length}]rawptr) -> SymbolValue {
            //l     ret: rawptr
            //reduce.lhs.type
              //w ; this: ${type}
              //reduce.rhs child idx
                //child.type
                  //w ; _${idx} := deref(children[${idx}], ${type})
                //e
              //e
              //reduce.code
                //l ${code}
              //e
              //l   ret = new_clone(this)
            //e
            //w ; return { .${reduce.lhs.enum}, ret }
            //l   })
            //l continue
          //e
        //e
        }
    //e
    }

    if errors > 0 {
      if state in HANDLES_ERRORS {
        append(&stack, SymbolValue{ .ERR, nil })
        continue
      }

      if len(stack) == 0 do return SymbolValue{ .ERR, nil }
      pop(&stack)
      continue
    }

    if symbol != .ERR {
      append(&stack, SymbolValue{ .ERR, nil })
      continue
    }

    if len(shifted) == 0 do return SymbolValue{ .ERR, nil }
    state = shifted[len(shifted) - 1].state
    resize_soa(&shifted, len(shifted) - 1)
    continue
  }
}
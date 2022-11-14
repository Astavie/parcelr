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
    symbols := make([dynamic]Symbol)
    if len(os.args) >= 2 {
      for s in os.args[1:] {
        for w in strings.split(s, " ") {
          switch w {
          //lexeme
            //l case "${lexeme.name}": append(&symbols, Symbol.${lexeme.enum})
          //e
            case: append(&symbols, Symbol.ERR)
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
  errors := 0

  defer delete(stack)
  defer delete(shifted)

  peek :: proc(a: []Symbol) -> Symbol {
    i := len(a) - 1
    if i >= 0 do return a[i]
    return Symbol.EOF
  }

  shift :: proc(stack: ^[dynamic]Symbol, shifted: ^[dynamic]State, state: ^int, new_state: int, errors: ^int) {
    symbol := pop_safe(stack) or_else Symbol.EOF
    if symbol == .ERR do errors^ += 1
    append(shifted, State { symbol, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]Symbol, shifted: ^[dynamic]State, state: ^int, errors: ^int, f: $T/proc(symbols: [$N]Symbol) -> Symbol) {
    symbols : [N]Symbol = ---
    when N > 0 {
      state^ = shifted[len(shifted) - N].state
    }
    for i := N - 1; i >= 0; i -= 1 {
      symbols[i] = pop(shifted).symbol
      if symbols[i] == .ERR do errors^ -= 1
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
            //l return shifted[0].symbol
          //e
          //lah.shift
            //l shift(&stack, &shifted, &state, ${shift}, &errors)
            //l continue
          //e
          //lah.reduce
            //l when PARCELR_DEBUG { fmt.println("reduce ${reduce}") }
            //l reduce(&stack, &shifted, &state, &errors,
            //l   proc (symbols: [${reduce.rhs.length}]Symbol) -> Symbol { return Symbol.${reduce.lhs.enum} })
            //l continue
          //e
        //e
        }
    //e
    }

    if errors > 0 {
      if symbol != .ERR && state in HANDLES_ERRORS {
        append(&stack, Symbol.ERR)
        continue
      }
      
      if len(stack) == 0 do return .ERR
      pop(&stack)
      continue
    }
    
    if symbol != .ERR {
      append(&stack, Symbol.ERR)
      continue
    }
    
    if len(shifted) == 0 do return .ERR
    popped_state := pop(&shifted)
    state = popped_state.state
    continue
  }
}

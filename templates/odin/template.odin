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

SymbolValue :: struct #raw_union {} //d
//l SymbolValue :: struct #raw_union {
//symbol
  //symbol.type
    //w  ${symbol.enum}: ${symbol.type},
  //e
//e
//w  }

SymbolPair :: struct { symbol: Symbol, value: SymbolValue }

HANDLES_ERRORS := map[int]struct{}{} //d
//l HANDLES_ERRORS := map[int]struct{}{
//state
  //state.lookahead.symbol.enum."ERR"
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
    symbols := make([dynamic]SymbolPair)
    defer delete(symbols)

    if len(os.args) >= 2 {
      for s in os.args[1:] {
        strs := strings.split(s, " ")
        defer delete(strs)

        for w in strs {
          switch w {
          //lexeme
            //l case "${lexeme.name}": append(&symbols, SymbolPair{ .${lexeme.enum}, --- })
          //e
            case: append(&symbols, SymbolPair{ .ERR, --- })
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

parse :: proc(lexemes: []SymbolPair) -> bool { // d
//l parse :: proc(lexemes: []SymbolPair) -> (
//rule.0.lhs.type
  //w ${type},
//e
//w bool) {
  stack := slice.clone_to_dynamic(lexemes)

  n := len(stack)/2
  for i in 0..<n {
    a, b := i, len(stack)-i-1
    tmp := stack[b]
    stack[b] = stack[a]
    stack[a] = tmp
  }

  State :: struct { symbol: Symbol, value: SymbolValue, state: int }

  shifted: #soa[dynamic]State
  state := 0
  errors := 0

  defer delete(stack)
  defer delete_soa(shifted)

  peek :: proc(a: []SymbolPair) -> Symbol {
    i := len(a) - 1
    if i >= 0 do return a[i].symbol
    return .EOF
  }

  shift :: proc(stack: ^[dynamic]SymbolPair, shifted: ^#soa[dynamic]State, state: ^int, new_state: int, errors: ^int) {
    val := pop_safe(stack) or_else SymbolPair{ .EOF, --- }
    if val.symbol == .ERR do errors^ += 1
    append_soa(shifted, State { val.symbol, val.value, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]SymbolPair, shifted: ^#soa[dynamic]State, state: ^int, errors: ^int, f: $T/proc(children: [$N]SymbolValue) -> SymbolPair) {
    vals: [N]SymbolValue = ---
    when N > 0 {
      _, values, _ := soa_unzip(shifted^[:])
      copy_slice(vals[:], values[len(values) - N:])
      state^ = shifted[len(shifted) - N].state
      resize_soa(shifted, len(shifted) - N)
    }
    append(stack, f(vals))
  }

  when PARCELR_DEBUG {
    dump :: proc(stack: [dynamic]SymbolPair, shifted: #soa[dynamic]State, state: int, size: int) {
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
            //l when PARCELR_DEBUG {
            //l   dump(stack, shifted, state, 2)
            //l   fmt.println()
            //l }
            //l return
            //rule.0.lhs.type
              //w  shifted[0].value.${rule.0.lhs.enum},
            //e
            //w  true
          //e
          //lah.shift
            //l shift(&stack, &shifted, &state, ${shift}, &errors)
            //l continue
          //e
          //lah.reduce
            //l when PARCELR_DEBUG {
            //l   dump(stack, shifted, state, ${reduce.rhs.length})
            //l   fmt.println("    reduce ${reduce}")
            //l }
            //l reduce(&stack, &shifted, &state, &errors,
            //l   proc (children: [${reduce.rhs.length}]SymbolValue) -> SymbolPair {
            //l     ret: SymbolValue
            //reduce.lhs.type
              //w ; this: ${type}
              //reduce.rhs child index
                //child.type
                  //w ; _${index} := children[${index}].${child.enum}
                //e
              //e
              //reduce.code
                //l ${code}
              //e
              //l   ret.${reduce.lhs.enum} = this
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
        append(&stack, SymbolPair{ .ERR, --- })
        continue
      }

      if len(stack) == 0 do return false //d
      //l if len(stack) == 0 do return
      //rule.0.lhs.type
        //w  ---,
      //e
      //w  false
      pop(&stack)
      continue
    }

    if symbol != .ERR {
      append(&stack, SymbolPair{ .ERR, --- })
      continue
    }

    if len(shifted) == 0 do return false //d
    //l if len(shifted) == 0 do return
    //rule.0.lhs.type
      //w  ---,
    //e
    //w  false
    state = shifted[len(shifted) - 1].state
    resize_soa(&shifted, len(shifted) - 1)
    continue
  }
}

package parser

import "core:slice"
import "core:fmt"
import "core:os"

Token :: enum { EOF } //d

//w Token :: enum {
//token
  //w  ${token}
  //s ,
//e
//w  }

PARCELR_DEBUG :: false

when PARCELR_DEBUG {
  main :: proc() {
    tokens := make([dynamic]Token) 
    if len(os.args) >= 2 {
      for s in os.args[1:] {
        switch s {
        //lexeme
          //l case "${lexeme}": append(&tokens, Token.${lexeme})
        //e
          case: panic(fmt.tprintf("Unknown token %v", s))
        }
      }
    }
    fmt.println(parse(tokens[:]))
  }
}

parse :: proc(lexemes: []Token) -> Token {
  stack := slice.clone_to_dynamic(lexemes)
  slice.reverse(stack[:])

  State :: struct { token: Token, state: int }
  
  shifted := make([dynamic]State)
  state := 0

  defer delete(stack)
  defer delete(shifted)

  peek :: proc(a: []Token) -> Token {
    i := len(a) - 1
    if i >= 0 do return a[i]
    return Token.EOF
  }

  shift :: proc(stack: ^[dynamic]Token, shifted: ^[dynamic]State, state: ^int, new_state: int) {
    append(shifted, State { pop_safe(stack) or_else Token.EOF, state^ })
    state^ = new_state
  }

  reduce :: proc(stack: ^[dynamic]Token, shifted: ^[dynamic]State, state: ^int, f: $T/proc(tokens: [$N]Token) -> Token) {
    tokens : [N]Token = ---
    when N > 0 {
      state^ = shifted[len(shifted) - N].state
    }
    for i := N - 1; i >= 0; i -= 1 {
      tokens[i] = pop(shifted).token
    }
    append(stack, f(tokens))
  }

  for {
    when PARCELR_DEBUG {
      fmt.printf("%v: %v %v\n", state, shifted[:], stack[:])
    }
    token := peek(stack[:])
    switch state {
    //state
      //l case ${state.index}:
      case 0: //d
        switch token {
          case .EOF: //d
        //state.lookahead lah
          //w case 
          //lah.token
            //w  .${token}
            //s ,
          //e
          //w :
          //lah.accept
            //l return shifted[0].token
          //e
          //lah.shift
            //l shift(&stack, &shifted, &state, ${shift})
            //l continue
          //e
          //lah.reduce
            //l reduce(&stack, &shifted, &state,
            //l   proc (tokens: [${reduce.rhs.length}]Token) -> Token { return Token.${reduce.lhs} })
            //l continue
          //e
        //e
          case:
            tokens :: [?]Token{ .EOF } //d
            //w tokens :: [?]Token{
            //state.lookahead lah
            //lah.token
              //w  .${token}
              //s ,
            //e
              //s ,
            //e
            //w  }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
    //e
    }
  }
}

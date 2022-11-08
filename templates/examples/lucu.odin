package parser

import "core:slice"
import "core:fmt"
import "core:os"

Token :: enum {
  EOF,
  lucu,
  definition,
  _context,
  id,
  typeorvalue,
  _val,
  _decl,
  type,
  _eq,
  expr,
  _fun,
  inputs,
  _do,
  outputs,
  block,
  CALL,
  _po,
  _pc,
  param,
  params,
  _c,
  ids,
  _ctx,
  ret,
  rets,
  closure,
  _pipe,
  funlit,
  _ref,
  assop,
  _concateq,
  stmnt,
  asslhs,
  _if,
  expr4,
  elseblock,
  _break,
  _return,
  _else,
  expr3,
  _then,
  expr2,
  _concat,
  expr1,
  _dot,
  arglist,
  __stack,
  stringlit,
  arg,
  args,
  _bo,
  stmnts,
  _bc,
}

PARCELR_DEBUG :: true

when PARCELR_DEBUG {
  main :: proc() {
    tokens := make([dynamic]Token) 
    if len(os.args) >= 2 {
      for s in os.args[1:] {
        switch s {
          case "_context": append(&tokens, Token._context)
          case "id": append(&tokens, Token.id)
          case "_val": append(&tokens, Token._val)
          case "_decl": append(&tokens, Token._decl)
          case "_eq": append(&tokens, Token._eq)
          case "_fun": append(&tokens, Token._fun)
          case "_do": append(&tokens, Token._do)
          case "CALL": append(&tokens, Token.CALL)
          case "_po": append(&tokens, Token._po)
          case "_pc": append(&tokens, Token._pc)
          case "_c": append(&tokens, Token._c)
          case "_ctx": append(&tokens, Token._ctx)
          case "_pipe": append(&tokens, Token._pipe)
          case "_ref": append(&tokens, Token._ref)
          case "_concateq": append(&tokens, Token._concateq)
          case "_if": append(&tokens, Token._if)
          case "_break": append(&tokens, Token._break)
          case "_return": append(&tokens, Token._return)
          case "_else": append(&tokens, Token._else)
          case "_then": append(&tokens, Token._then)
          case "_concat": append(&tokens, Token._concat)
          case "_dot": append(&tokens, Token._dot)
          case "__stack": append(&tokens, Token.__stack)
          case "stringlit": append(&tokens, Token.stringlit)
          case "_bo": append(&tokens, Token._bo)
          case "_bc": append(&tokens, Token._bc)
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
      case 0:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.lucu })
            continue
          case Token.lucu:
            shift(&stack, &shifted, &state, 1)
            continue
          case Token.definition:
            shift(&stack, &shifted, &state, 2)
            continue
          case Token._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case Token._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case Token._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token.lucu,
              Token.definition,
              Token._context,
              Token._val,
              Token._decl,
              Token._fun,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 1:
        #partial switch token {
          case Token.EOF:
            return shifted[0].token
          case:
            tokens :: [?]Token{
              Token.EOF,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 2:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.lucu })
            continue
          case Token.lucu:
            shift(&stack, &shifted, &state, 7)
            continue
          case Token.definition:
            shift(&stack, &shifted, &state, 2)
            continue
          case Token._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case Token._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case Token._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token.lucu,
              Token.definition,
              Token._context,
              Token._val,
              Token._decl,
              Token._fun,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 3:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 8)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 4:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 9)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 5:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 10)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 6:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 7:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.lucu })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 8:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.typeorvalue:
            shift(&stack, &shifted, &state, 12)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 13)
            continue
          case Token._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.typeorvalue,
              Token.type,
              Token._eq,
              Token._fun,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 9:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.typeorvalue:
            shift(&stack, &shifted, &state, 18)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 13)
            continue
          case Token._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.typeorvalue,
              Token.type,
              Token._eq,
              Token._fun,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 10:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 19)
            continue
          case Token._eq:
            shift(&stack, &shifted, &state, 20)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._eq,
              Token._fun,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 11:
        #partial switch token {
          case Token.inputs:
            shift(&stack, &shifted, &state, 21)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{
              Token.inputs,
              Token.CALL,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 12:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 13:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._eq:
            shift(&stack, &shifted, &state, 23)
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 14:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 24)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 15:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 40)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 16:
        #partial switch token {
          case Token.inputs:
            shift(&stack, &shifted, &state, 41)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{
              Token.inputs,
              Token.CALL,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 17:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 18:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 19:
        #partial switch token {
          case Token._eq:
            shift(&stack, &shifted, &state, 42)
            continue
          case:
            tokens :: [?]Token{
              Token._eq,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 20:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 43)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 21:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 49)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._do:
            shift(&stack, &shifted, &state, 44)
            continue
          case Token.outputs:
            shift(&stack, &shifted, &state, 45)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 46)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case Token.ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._do,
              Token.outputs,
              Token.block,
              Token.CALL,
              Token._ctx,
              Token.ret,
              Token._ref,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 22:
        #partial switch token {
          case Token._po:
            shift(&stack, &shifted, &state, 51)
            continue
          case:
            tokens :: [?]Token{
              Token._po,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 23:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 52)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 24:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 25:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 26:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._else:
            shift(&stack, &shifted, &state, 53)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 27:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 54)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 28:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._concat:
            shift(&stack, &shifted, &state, 58)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._concat,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 29:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 30:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 31:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 32:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 33:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 34:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 35:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 36:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 65)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 64)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token._pc:
            shift(&stack, &shifted, &state, 63)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token.arg:
            shift(&stack, &shifted, &state, 62)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token._pc,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token.arg,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 37:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._concateq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._concateq,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 38:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case Token.stmnts:
            shift(&stack, &shifted, &state, 66)
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token.stmnts,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 39:
        #partial switch token {
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.closure })
            continue
          case Token.closure:
            shift(&stack, &shifted, &state, 67)
            continue
          case Token._pipe:
            shift(&stack, &shifted, &state, 68)
            continue
          case:
            tokens :: [?]Token{
              Token.CALL,
              Token.closure,
              Token._pipe,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 40:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 41:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 49)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token.outputs:
            shift(&stack, &shifted, &state, 69)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case Token.ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token.outputs,
              Token.CALL,
              Token._ctx,
              Token.ret,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 42:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 70)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 43:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 44:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 71)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 45:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 72)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 46:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 47:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 48:
        #partial switch token {
          case Token._po:
            shift(&stack, &shifted, &state, 73)
            continue
          case:
            tokens :: [?]Token{
              Token._po,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 49:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 50:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 74)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 51:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 77)
            continue
          case Token._pc:
            shift(&stack, &shifted, &state, 75)
            continue
          case Token.param:
            shift(&stack, &shifted, &state, 76)
            continue
          case Token.ids:
            shift(&stack, &shifted, &state, 78)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 79)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._pc,
              Token.param,
              Token.ids,
              Token._ctx,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 52:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 53:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 80)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 81)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 54:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 83)
            continue
          case Token._then:
            shift(&stack, &shifted, &state, 82)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._then,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 55:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._else:
            shift(&stack, &shifted, &state, 84)
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 56:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._concat:
            shift(&stack, &shifted, &state, 85)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 57:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 86)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 58:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 87)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 88)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 59:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._concateq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._concateq,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 60:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 89)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 61:
        #partial switch token {
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 90)
            continue
          case:
            tokens :: [?]Token{
              Token._po,
              Token.arglist,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 62:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.args })
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 92)
            continue
          case Token.args:
            shift(&stack, &shifted, &state, 91)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
              Token.args,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 63:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 64:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.arg })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.arg })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 65:
        #partial switch token {
          case Token._eq:
            shift(&stack, &shifted, &state, 93)
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{
              Token._eq,
              Token.CALL,
              Token._pc,
              Token._c,
              Token._ref,
              Token._else,
              Token._concat,
              Token._dot,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 66:
        #partial switch token {
          case Token.definition:
            shift(&stack, &shifted, &state, 97)
            continue
          case Token._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case Token._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 96)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.stmnt:
            shift(&stack, &shifted, &state, 95)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 98)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 99)
            continue
          case Token._break:
            shift(&stack, &shifted, &state, 100)
            continue
          case Token._return:
            shift(&stack, &shifted, &state, 101)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 102)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case Token._bc:
            shift(&stack, &shifted, &state, 94)
            continue
          case:
            tokens :: [?]Token{
              Token.definition,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token.block,
              Token._po,
              Token.stmnt,
              Token.asslhs,
              Token._if,
              Token._break,
              Token._return,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 67:
        #partial switch token {
          case Token.inputs:
            shift(&stack, &shifted, &state, 103)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{
              Token.inputs,
              Token.CALL,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 68:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 104)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 69:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 70:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 71:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 72:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 73:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 49)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._pc:
            shift(&stack, &shifted, &state, 105)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case Token.ret:
            shift(&stack, &shifted, &state, 106)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._pc,
              Token._ctx,
              Token.ret,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 74:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 75:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token._ctx:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._ctx,
              Token._ref,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 76:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.params })
            continue
          case Token.params:
            shift(&stack, &shifted, &state, 107)
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 108)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token.params,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 77:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.typeorvalue:
            shift(&stack, &shifted, &state, 109)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 13)
            continue
          case Token._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 110)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.typeorvalue,
              Token.type,
              Token._eq,
              Token._fun,
              Token._c,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 78:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 111)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 112)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._c,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 79:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 113)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 80:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 81:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._then,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 82:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 114)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 115)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 83:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 84:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 81)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 85:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 88)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 86:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 83)
            continue
          case Token._then:
            shift(&stack, &shifted, &state, 116)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._then,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 87:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 88:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 89:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._concateq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._concateq,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 90:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 91:
        #partial switch token {
          case Token._pc:
            shift(&stack, &shifted, &state, 117)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 92:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 65)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 64)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token.arg:
            shift(&stack, &shifted, &state, 118)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token.arg,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 93:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 119)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 94:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 95:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 96:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token.CALL,
              Token._po,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 97:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 98:
        #partial switch token {
          case Token._eq:
            shift(&stack, &shifted, &state, 122)
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case Token.assop:
            shift(&stack, &shifted, &state, 120)
            continue
          case Token._concateq:
            shift(&stack, &shifted, &state, 121)
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{
              Token._eq,
              Token.CALL,
              Token._ref,
              Token.assop,
              Token._concateq,
              Token._dot,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 99:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 123)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 100:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 101:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 124)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 102:
        #partial switch token {
          case Token.CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case Token._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case:
            tokens :: [?]Token{
              Token.CALL,
              Token._ref,
              Token._dot,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 103:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 49)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._do:
            shift(&stack, &shifted, &state, 125)
            continue
          case Token.outputs:
            shift(&stack, &shifted, &state, 126)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 127)
            continue
          case Token.CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case Token.ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._do,
              Token.outputs,
              Token.block,
              Token.CALL,
              Token._ctx,
              Token.ret,
              Token._ref,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 104:
        #partial switch token {
          case Token._pipe:
            shift(&stack, &shifted, &state, 128)
            continue
          case:
            tokens :: [?]Token{
              Token._pipe,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 105:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 106:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.rets })
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 130)
            continue
          case Token.rets:
            shift(&stack, &shifted, &state, 129)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
              Token.rets,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 107:
        #partial switch token {
          case Token._pc:
            shift(&stack, &shifted, &state, 131)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 108:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 77)
            continue
          case Token.param:
            shift(&stack, &shifted, &state, 132)
            continue
          case Token.ids:
            shift(&stack, &shifted, &state, 78)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 79)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.param,
              Token.ids,
              Token._ctx,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 109:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 110:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 133)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 111:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 112:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 134)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 113:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 114:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 115:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 116:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 115)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 117:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._else:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._then:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._concat:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._po,
              Token._pc,
              Token._c,
              Token._ref,
              Token._if,
              Token._break,
              Token._return,
              Token._else,
              Token._then,
              Token._concat,
              Token._dot,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 118:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.args })
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 92)
            continue
          case Token.args:
            shift(&stack, &shifted, &state, 135)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
              Token.args,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 119:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.arg })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.arg })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 120:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 136)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 121:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._po,
              Token._if,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 122:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._po,
              Token._if,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 123:
        #partial switch token {
          case Token._do:
            shift(&stack, &shifted, &state, 137)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 138)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token._do,
              Token.block,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 124:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 125:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.expr:
            shift(&stack, &shifted, &state, 139)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.expr,
              Token._fun,
              Token.block,
              Token._po,
              Token.funlit,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 126:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 140)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 127:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 128:
        #partial switch token {
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.closure })
            continue
          case:
            tokens :: [?]Token{
              Token.CALL,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 129:
        #partial switch token {
          case Token._pc:
            shift(&stack, &shifted, &state, 141)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 130:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 17)
            continue
          case Token.type:
            shift(&stack, &shifted, &state, 49)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case Token._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case Token.ret:
            shift(&stack, &shifted, &state, 142)
            continue
          case Token._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.type,
              Token._fun,
              Token._ctx,
              Token.ret,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 131:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token._do:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token.CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token._ctx:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._do,
              Token.CALL,
              Token._ctx,
              Token._ref,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 132:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.params })
            continue
          case Token.params:
            shift(&stack, &shifted, &state, 143)
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 108)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token.params,
              Token._c,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 133:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._c,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 134:
        #partial switch token {
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case Token._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token._fun,
              Token._c,
              Token._ref,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 135:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.args })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 136:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 137:
        #partial switch token {
          case Token.definition:
            shift(&stack, &shifted, &state, 97)
            continue
          case Token._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case Token._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case Token._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 96)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.stmnt:
            shift(&stack, &shifted, &state, 144)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 98)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 99)
            continue
          case Token._break:
            shift(&stack, &shifted, &state, 100)
            continue
          case Token._return:
            shift(&stack, &shifted, &state, 101)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 102)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.definition,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token.block,
              Token._po,
              Token.stmnt,
              Token.asslhs,
              Token._if,
              Token._break,
              Token._return,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 138:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.elseblock:
            shift(&stack, &shifted, &state, 145)
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._else:
            shift(&stack, &shifted, &state, 146)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token.elseblock,
              Token._break,
              Token._return,
              Token._else,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 139:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 140:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 141:
        #partial switch token {
          case Token.EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._eq:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{
              Token.EOF,
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._eq,
              Token._fun,
              Token._po,
              Token._pc,
              Token._c,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 142:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.rets })
            continue
          case Token._c:
            shift(&stack, &shifted, &state, 130)
            continue
          case Token.rets:
            shift(&stack, &shifted, &state, 147)
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
              Token._c,
              Token.rets,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 143:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.params })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 144:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 145:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 146:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 148)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 149)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._if,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 147:
        #partial switch token {
          case Token._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.rets })
            continue
          case:
            tokens :: [?]Token{
              Token._pc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 148:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 149:
        #partial switch token {
          case Token.id:
            shift(&stack, &shifted, &state, 37)
            continue
          case Token.block:
            shift(&stack, &shifted, &state, 31)
            continue
          case Token._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case Token.asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case Token._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case Token.expr4:
            shift(&stack, &shifted, &state, 150)
            continue
          case Token.expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case Token.expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case Token.expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case Token.arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case Token.__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case Token.stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.id,
              Token.block,
              Token._po,
              Token.asslhs,
              Token._if,
              Token.expr4,
              Token.expr3,
              Token.expr2,
              Token.expr1,
              Token.arglist,
              Token.__stack,
              Token.stringlit,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 150:
        #partial switch token {
          case Token.block:
            shift(&stack, &shifted, &state, 151)
            continue
          case Token._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{
              Token.block,
              Token._bo,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 151:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.elseblock:
            shift(&stack, &shifted, &state, 152)
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._else:
            shift(&stack, &shifted, &state, 146)
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token.elseblock,
              Token._break,
              Token._return,
              Token._else,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 152:
        #partial switch token {
          case Token._context:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token.id:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._val:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._decl:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._fun:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._po:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._if:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._break:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._return:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token.__stack:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token.stringlit:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case Token._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{
              Token._context,
              Token.id,
              Token._val,
              Token._decl,
              Token._fun,
              Token._po,
              Token._if,
              Token._break,
              Token._return,
              Token.__stack,
              Token.stringlit,
              Token._bo,
              Token._bc,
            }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
    }
  }
}


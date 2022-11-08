package parser

import "core:slice"
import "core:fmt"
import "core:os"


Token :: enum { EOF, lucu, definition, _context, id, typeorvalue, _val, _decl, type, _eq, expr, _fun, inputs, _do, outputs, block, CALL, _po, _pc, param, params, _c, ids, _ctx, ret, rets, closure, _pipe, funlit, _ref, assop, _concateq, stmnt, asslhs, _if, expr4, elseblock, _break, _return, _else, expr3, _then, expr2, _concat, expr1, _dot, arglist, __stack, stringlit, arg, args, _bo, stmnts, _bc }

PARCELR_DEBUG :: false

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
        switch token {
          case .EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.lucu })
            continue
          case .lucu:
            shift(&stack, &shifted, &state, 1)
            continue
          case .definition:
            shift(&stack, &shifted, &state, 2)
            continue
          case ._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case ._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case ._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case:
            tokens :: [?]Token{ .EOF, .lucu, .definition, ._context, ._val, ._decl, ._fun }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 1:
        switch token {
          case .EOF:
            return shifted[0].token
          case:
            tokens :: [?]Token{ .EOF }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 2:
        switch token {
          case .EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.lucu })
            continue
          case .lucu:
            shift(&stack, &shifted, &state, 7)
            continue
          case .definition:
            shift(&stack, &shifted, &state, 2)
            continue
          case ._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case ._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case ._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case:
            tokens :: [?]Token{ .EOF, .lucu, .definition, ._context, ._val, ._decl, ._fun }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 3:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 8)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 4:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 9)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 5:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 10)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 6:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 11)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 7:
        switch token {
          case .EOF:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.lucu })
            continue
          case:
            tokens :: [?]Token{ .EOF }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 8:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .typeorvalue:
            shift(&stack, &shifted, &state, 12)
            continue
          case .type:
            shift(&stack, &shifted, &state, 13)
            continue
          case ._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .typeorvalue, .type, ._eq, ._fun, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 9:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .typeorvalue:
            shift(&stack, &shifted, &state, 18)
            continue
          case .type:
            shift(&stack, &shifted, &state, 13)
            continue
          case ._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .typeorvalue, .type, ._eq, ._fun, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 10:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 19)
            continue
          case ._eq:
            shift(&stack, &shifted, &state, 20)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._eq, ._fun, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 11:
        switch token {
          case .inputs:
            shift(&stack, &shifted, &state, 21)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{ .inputs, .CALL }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 12:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 13:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.typeorvalue })
            continue
          case ._eq:
            shift(&stack, &shifted, &state, 23)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, ._eq }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 14:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 24)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 15:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 40)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 16:
        switch token {
          case .inputs:
            shift(&stack, &shifted, &state, 41)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{ .inputs, .CALL }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 17:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 18:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 19:
        switch token {
          case ._eq:
            shift(&stack, &shifted, &state, 42)
            continue
          case:
            tokens :: [?]Token{ ._eq }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 20:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 43)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 21:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 49)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._do:
            shift(&stack, &shifted, &state, 44)
            continue
          case .outputs:
            shift(&stack, &shifted, &state, 45)
            continue
          case .block:
            shift(&stack, &shifted, &state, 46)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case .ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._do, .outputs, .block, .CALL, ._ctx, .ret, ._ref, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 22:
        switch token {
          case ._po:
            shift(&stack, &shifted, &state, 51)
            continue
          case:
            tokens :: [?]Token{ ._po }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 23:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 52)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 24:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.typeorvalue })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 25:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 26:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case ._else:
            shift(&stack, &shifted, &state, 53)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, ._else }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 27:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 54)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 28:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case ._concat:
            shift(&stack, &shifted, &state, 58)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, .__stack, .stringlit, ._bo, ._bc, ._concat }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 29:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 30:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, ._concat, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr2 })
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case ._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, ._concat, .__stack, .stringlit, ._bo, ._bc, .CALL, ._ref, ._dot }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 31:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 32:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 33:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 34:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 35:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 36:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 65)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 64)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case ._pc:
            shift(&stack, &shifted, &state, 63)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case .arg:
            shift(&stack, &shifted, &state, 62)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, ._pc, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, .arg, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 37:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 38:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.stmnts })
            continue
          case .stmnts:
            shift(&stack, &shifted, &state, 66)
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, .stmnts }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 39:
        switch token {
          case .CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.closure })
            continue
          case .closure:
            shift(&stack, &shifted, &state, 67)
            continue
          case ._pipe:
            shift(&stack, &shifted, &state, 68)
            continue
          case:
            tokens :: [?]Token{ .CALL, .closure, ._pipe }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 40:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 41:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 49)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case .outputs:
            shift(&stack, &shifted, &state, 69)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case .ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, .outputs, .CALL, ._ctx, .ret, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 42:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 70)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 43:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 44:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 71)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 45:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 72)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 46:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 47:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 48:
        switch token {
          case ._po:
            shift(&stack, &shifted, &state, 73)
            continue
          case:
            tokens :: [?]Token{ ._po }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 49:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.ret })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 50:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 74)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 51:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 77)
            continue
          case ._pc:
            shift(&stack, &shifted, &state, 75)
            continue
          case .param:
            shift(&stack, &shifted, &state, 76)
            continue
          case .ids:
            shift(&stack, &shifted, &state, 78)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 79)
            continue
          case:
            tokens :: [?]Token{ .id, ._pc, .param, .ids, ._ctx }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 52:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.typeorvalue })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 53:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 80)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 81)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 54:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 83)
            continue
          case ._then:
            shift(&stack, &shifted, &state, 82)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._then, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 55:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._then, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr4 })
            continue
          case ._else:
            shift(&stack, &shifted, &state, 84)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._then, .__stack, .stringlit, ._bo, ._bc, ._else }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 56:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr3 })
            continue
          case ._concat:
            shift(&stack, &shifted, &state, 85)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc, ._concat }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 57:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 86)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 58:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 87)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 88)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, .block, ._po, .funlit, .asslhs, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 59:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 60:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 89)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 61:
        switch token {
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 90)
            continue
          case:
            tokens :: [?]Token{ ._po, .arglist }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 62:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.args })
            continue
          case ._c:
            shift(&stack, &shifted, &state, 92)
            continue
          case .args:
            shift(&stack, &shifted, &state, 91)
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c, .args }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 63:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.arglist })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 64:
        switch token {
          case ._pc, ._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.arg })
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 65:
        switch token {
          case ._eq:
            shift(&stack, &shifted, &state, 93)
            continue
          case .CALL, ._pc, ._c, ._ref, ._else, ._concat, ._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{ ._eq, .CALL, ._pc, ._c, ._ref, ._else, ._concat, ._dot }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 66:
        switch token {
          case .definition:
            shift(&stack, &shifted, &state, 97)
            continue
          case ._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case ._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case ._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case .block:
            shift(&stack, &shifted, &state, 96)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .stmnt:
            shift(&stack, &shifted, &state, 95)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 98)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 99)
            continue
          case ._break:
            shift(&stack, &shifted, &state, 100)
            continue
          case ._return:
            shift(&stack, &shifted, &state, 101)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 102)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case ._bc:
            shift(&stack, &shifted, &state, 94)
            continue
          case:
            tokens :: [?]Token{ .definition, ._context, .id, ._val, ._decl, ._fun, .block, ._po, .stmnt, .asslhs, ._if, ._break, ._return, .expr1, .arglist, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 67:
        switch token {
          case .inputs:
            shift(&stack, &shifted, &state, 103)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 22)
            continue
          case:
            tokens :: [?]Token{ .inputs, .CALL }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 68:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 104)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 69:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.type })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 70:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 71:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 72:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.definition })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 73:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 49)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._pc:
            shift(&stack, &shifted, &state, 105)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case .ret:
            shift(&stack, &shifted, &state, 106)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._pc, ._ctx, .ret, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 74:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.ret })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 75:
        switch token {
          case .id, ._fun, ._do, .CALL, ._ctx, ._ref, ._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.inputs })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._do, .CALL, ._ctx, ._ref, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 76:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.params })
            continue
          case .params:
            shift(&stack, &shifted, &state, 107)
            continue
          case ._c:
            shift(&stack, &shifted, &state, 108)
            continue
          case:
            tokens :: [?]Token{ ._pc, .params, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 77:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .typeorvalue:
            shift(&stack, &shifted, &state, 109)
            continue
          case .type:
            shift(&stack, &shifted, &state, 13)
            continue
          case ._eq:
            shift(&stack, &shifted, &state, 14)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._c:
            shift(&stack, &shifted, &state, 110)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .typeorvalue, .type, ._eq, ._fun, ._c, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 78:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 111)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._c:
            shift(&stack, &shifted, &state, 112)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._c, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 79:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 113)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 80:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 81:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._then, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr4 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._then, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 82:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 114)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 115)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 83:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 84:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 81)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 85:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 88)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 86:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 83)
            continue
          case ._then:
            shift(&stack, &shifted, &state, 116)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._then, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 87:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 88:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, ._concat, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr2 })
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case ._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, ._concat, .__stack, .stringlit, ._bo, ._bc, .CALL, ._ref, ._dot }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 89:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.asslhs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._concateq, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 90:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 91:
        switch token {
          case ._pc:
            shift(&stack, &shifted, &state, 117)
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 92:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 65)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 64)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case .arg:
            shift(&stack, &shifted, &state, 118)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, .arg, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 93:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 119)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 94:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.block })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 95:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnts })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 96:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case .CALL, ._ref, ._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, .CALL, ._ref, ._dot }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 97:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 98:
        switch token {
          case ._eq:
            shift(&stack, &shifted, &state, 122)
            continue
          case .CALL, ._ref, ._dot:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.expr1 })
            continue
          case .assop:
            shift(&stack, &shifted, &state, 120)
            continue
          case ._concateq:
            shift(&stack, &shifted, &state, 121)
            continue
          case:
            tokens :: [?]Token{ ._eq, .CALL, ._ref, ._dot, .assop, ._concateq }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 99:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 123)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 100:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 101:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 124)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 102:
        switch token {
          case .CALL:
            shift(&stack, &shifted, &state, 61)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 59)
            continue
          case ._dot:
            shift(&stack, &shifted, &state, 60)
            continue
          case:
            tokens :: [?]Token{ .CALL, ._ref, ._dot }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 103:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 49)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._do:
            shift(&stack, &shifted, &state, 125)
            continue
          case .outputs:
            shift(&stack, &shifted, &state, 126)
            continue
          case .block:
            shift(&stack, &shifted, &state, 127)
            continue
          case .CALL:
            shift(&stack, &shifted, &state, 48)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case .ret:
            shift(&stack, &shifted, &state, 47)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._do, .outputs, .block, .CALL, ._ctx, .ret, ._ref, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 104:
        switch token {
          case ._pipe:
            shift(&stack, &shifted, &state, 128)
            continue
          case:
            tokens :: [?]Token{ ._pipe }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 105:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 106:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.rets })
            continue
          case ._c:
            shift(&stack, &shifted, &state, 130)
            continue
          case .rets:
            shift(&stack, &shifted, &state, 129)
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c, .rets }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 107:
        switch token {
          case ._pc:
            shift(&stack, &shifted, &state, 131)
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 108:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 77)
            continue
          case .param:
            shift(&stack, &shifted, &state, 132)
            continue
          case .ids:
            shift(&stack, &shifted, &state, 78)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 79)
            continue
          case:
            tokens :: [?]Token{ .id, .param, .ids, ._ctx }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 109:
        switch token {
          case ._pc, ._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 110:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 133)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 111:
        switch token {
          case ._pc, ._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 112:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 134)
            continue
          case:
            tokens :: [?]Token{ .id }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 113:
        switch token {
          case ._pc, ._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.param })
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 114:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 115:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.expr3 })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, ._po, ._pc, ._c, ._if, ._break, ._return, ._else, ._then, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 116:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 115)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 117:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.arglist })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._do, .CALL, ._po, ._pc, ._c, ._ref, ._if, ._break, ._return, ._else, ._then, ._concat, ._dot, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 118:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.args })
            continue
          case ._c:
            shift(&stack, &shifted, &state, 92)
            continue
          case .args:
            shift(&stack, &shifted, &state, 135)
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c, .args }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 119:
        switch token {
          case ._pc, ._c:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.arg })
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 120:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 136)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 121:
        switch token {
          case .id, ._fun, ._po, ._if, .__stack, .stringlit, ._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._po, ._if, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 122:
        switch token {
          case .id, ._fun, ._po, ._if, .__stack, .stringlit, ._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [1]Token) -> Token { return Token.assop })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._po, ._if, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 123:
        switch token {
          case ._do:
            shift(&stack, &shifted, &state, 137)
            continue
          case .block:
            shift(&stack, &shifted, &state, 138)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ ._do, .block, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 124:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 125:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .expr:
            shift(&stack, &shifted, &state, 139)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 39)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .funlit:
            shift(&stack, &shifted, &state, 25)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 27)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 29)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 26)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 28)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .expr, ._fun, .block, ._po, .funlit, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 126:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 140)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 127:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 128:
        switch token {
          case .CALL:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.closure })
            continue
          case:
            tokens :: [?]Token{ .CALL }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 129:
        switch token {
          case ._pc:
            shift(&stack, &shifted, &state, 141)
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 130:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 17)
            continue
          case .type:
            shift(&stack, &shifted, &state, 49)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 16)
            continue
          case ._ctx:
            shift(&stack, &shifted, &state, 50)
            continue
          case .ret:
            shift(&stack, &shifted, &state, 142)
            continue
          case ._ref:
            shift(&stack, &shifted, &state, 15)
            continue
          case:
            tokens :: [?]Token{ .id, .type, ._fun, ._ctx, .ret, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 131:
        switch token {
          case .id, ._fun, ._do, .CALL, ._ctx, ._ref, ._bo:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.inputs })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._do, .CALL, ._ctx, ._ref, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 132:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.params })
            continue
          case .params:
            shift(&stack, &shifted, &state, 143)
            continue
          case ._c:
            shift(&stack, &shifted, &state, 108)
            continue
          case:
            tokens :: [?]Token{ ._pc, .params, ._c }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 133:
        switch token {
          case .id, ._fun, ._c, ._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._c, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 134:
        switch token {
          case .id, ._fun, ._c, ._ref:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.ids })
            continue
          case:
            tokens :: [?]Token{ .id, ._fun, ._c, ._ref }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 135:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.args })
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 136:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 137:
        switch token {
          case .definition:
            shift(&stack, &shifted, &state, 97)
            continue
          case ._context:
            shift(&stack, &shifted, &state, 3)
            continue
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case ._val:
            shift(&stack, &shifted, &state, 4)
            continue
          case ._decl:
            shift(&stack, &shifted, &state, 5)
            continue
          case ._fun:
            shift(&stack, &shifted, &state, 6)
            continue
          case .block:
            shift(&stack, &shifted, &state, 96)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .stmnt:
            shift(&stack, &shifted, &state, 144)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 98)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 99)
            continue
          case ._break:
            shift(&stack, &shifted, &state, 100)
            continue
          case ._return:
            shift(&stack, &shifted, &state, 101)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 102)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .definition, ._context, .id, ._val, ._decl, ._fun, .block, ._po, .stmnt, .asslhs, ._if, ._break, ._return, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 138:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case .elseblock:
            shift(&stack, &shifted, &state, 145)
            continue
          case ._else:
            shift(&stack, &shifted, &state, 146)
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, .elseblock, ._else }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 139:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 140:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.funlit })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 141:
        switch token {
          case .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.outputs })
            continue
          case:
            tokens :: [?]Token{ .EOF, ._context, .id, ._val, ._decl, ._eq, ._fun, ._po, ._pc, ._c, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 142:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.rets })
            continue
          case ._c:
            shift(&stack, &shifted, &state, 130)
            continue
          case .rets:
            shift(&stack, &shifted, &state, 147)
            continue
          case:
            tokens :: [?]Token{ ._pc, ._c, .rets }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 143:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.params })
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 144:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 145:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [4]Token) -> Token { return Token.stmnt })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 146:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 148)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 149)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._if, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 147:
        switch token {
          case ._pc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [3]Token) -> Token { return Token.rets })
            continue
          case:
            tokens :: [?]Token{ ._pc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 148:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [2]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 149:
        switch token {
          case .id:
            shift(&stack, &shifted, &state, 37)
            continue
          case .block:
            shift(&stack, &shifted, &state, 31)
            continue
          case ._po:
            shift(&stack, &shifted, &state, 36)
            continue
          case .asslhs:
            shift(&stack, &shifted, &state, 32)
            continue
          case ._if:
            shift(&stack, &shifted, &state, 57)
            continue
          case .expr4:
            shift(&stack, &shifted, &state, 150)
            continue
          case .expr3:
            shift(&stack, &shifted, &state, 55)
            continue
          case .expr2:
            shift(&stack, &shifted, &state, 56)
            continue
          case .expr1:
            shift(&stack, &shifted, &state, 30)
            continue
          case .arglist:
            shift(&stack, &shifted, &state, 33)
            continue
          case .__stack:
            shift(&stack, &shifted, &state, 34)
            continue
          case .stringlit:
            shift(&stack, &shifted, &state, 35)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .id, .block, ._po, .asslhs, ._if, .expr4, .expr3, .expr2, .expr1, .arglist, .__stack, .stringlit, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 150:
        switch token {
          case .block:
            shift(&stack, &shifted, &state, 151)
            continue
          case ._bo:
            shift(&stack, &shifted, &state, 38)
            continue
          case:
            tokens :: [?]Token{ .block, ._bo }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 151:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [0]Token) -> Token { return Token.elseblock })
            continue
          case .elseblock:
            shift(&stack, &shifted, &state, 152)
            continue
          case ._else:
            shift(&stack, &shifted, &state, 146)
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc, .elseblock, ._else }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
      case 152:
        switch token {
          case ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc:
            reduce(&stack, &shifted, &state,
              proc (tokens: [5]Token) -> Token { return Token.elseblock })
            continue
          case:
            tokens :: [?]Token{ ._context, .id, ._val, ._decl, ._fun, ._po, ._if, ._break, ._return, .__stack, .stringlit, ._bo, ._bc }
            panic(fmt.tprintf("Unexpected %v, expected %v", token, tokens))
        }
    }
  }
}


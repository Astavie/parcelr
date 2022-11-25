package main

import "core:strings"
import "core:fmt"

Symbol :: distinct int
Lexeme :: distinct u8

Rule  :: distinct int
START :: Rule(0)

RuleDefinition :: struct {
  lhs: Symbol,
  rhs: []Symbol,
  code: string,
}

SymbolDefinition :: struct {
  name: string,
  enum_name: string,
  type: string,
}

Grammar :: struct {
  rules: []RuleDefinition,
  symbols: []SymbolDefinition,
  lexemes: []Symbol,
  preamble: string,
}

ROOT :: Symbol(0)
EOF  :: Lexeme(0)
ERR  :: Lexeme(1)

void :: struct{}

Error :: distinct string

delete_grammar :: proc(g: Grammar) {
  for rule in g.rules {
    delete(rule.rhs)
  }
  for symbol in g.symbols[3:] {
    delete(symbol.name)
    delete(symbol.enum_name)
  }
  delete(g.rules)
  delete(g.symbols)
  delete(g.lexemes)
}

parse :: proc(d: []u8) -> (Grammar, Error) {
  rules      := make([dynamic]RuleDefinition)
  symbols    := make([dynamic]SymbolDefinition)
  nonlexemes := make(map[Symbol]void)
  defer delete(nonlexemes)

  // append ROOT, EOF, and ERR symbols
  // the first symbol mentioned in the grammar file will be symbol 3
  rhs := make([]Symbol, 1)
  rhs[0] = Symbol(3)
  append(&rules, RuleDefinition { ROOT, rhs, {} })
  append(&symbols, SymbolDefinition{ "ROOT", {}, {} }) // won't show up in templates but it's nice for debug information
  append(&symbols, SymbolDefinition{ "$", "EOF", {} })
  append(&symbols, SymbolDefinition{ "error", "ERR", {} })

  nonlexemes[ROOT] = {}

  EXPR_ASSIGN :: "->"
  EXPR_DONE   :: ";"
  CODE_OPEN   :: "//"
  CODE_CLOSE  :: "//"

  get_symbol :: proc(symbols: ^[dynamic]SymbolDefinition, token: string) -> Symbol {
    name : string
    enum_name : string
    if token[0] == '"' && token[len(token) - 1] == '"' {
      name = strings.clone(token[1:len(token) - 1])
      enum_name = fmt.aprintf("_%i", len(symbols))
    } else {
      name = strings.clone(token)
      enum_name = strings.clone(token)
    }
    for sym, idx in symbols {
      if name == sym.name {
        delete(name)
        delete(enum_name)
        return Symbol(idx)
      }
    }
    append(symbols, SymbolDefinition{ name, enum_name, {} })
    return Symbol(len(symbols) - 1)
  }

  parse_token :: proc(data: ^[]u8) -> string {
    // skip whitespace
    start := 0
    a: for len(data) > start {
      switch data[start] {
        case '#':
          // skip line
          for len(data) > start && data[start] != '\n' {
            start += 1
          }
        case ' ', '\t', '\r', '\n':
          start += 1
        case:
          break a
      }
    }

    // get until whitespace
    end := start
    b: for len(data) > end {
      switch data[end] {
        case '#', ' ', '\t', '\r', '\n':
          break b
        case:
          end += 1
      }
    }

    ret := transmute(string)data[start:end]
    data^ = data[end:]
    return ret
  }

  parse_optional_code :: proc(data: ^[]u8) -> string {
    copy := data^

    token := parse_token(&copy)
    if token == CODE_OPEN {
      start := &copy[0]
      for {
        token := parse_token(&copy)
        if token == "" do return {}
        if token == CODE_CLOSE do break
      }
      end := &copy[0]
      length := uintptr(end) - len(CODE_CLOSE) - uintptr(start)
      data^ = copy
      return strings.trim_space(strings.string_from_ptr(start, int(length)))
    }

    return {}
  }

  data := d

  preamble := parse_optional_code(&data)

  for {
    token := parse_token(&data)

    if token == "" do break
    if token == CODE_OPEN {
      delete_grammar({ rules[:], symbols[:], {}, {} })
      return ---, "'" + CODE_CLOSE + "' expected"
    }
    if token == EXPR_DONE || token == EXPR_ASSIGN || token == CODE_CLOSE {
      delete_grammar({ rules[:], symbols[:], {}, {} })
      return ---, "lhs or EOF expected"
    }

    type := parse_optional_code(&data)

    {
      token := parse_token(&data)
      if token == CODE_OPEN {
        delete_grammar({ rules[:], symbols[:], {}, {} })
        return ---, "'" + EXPR_ASSIGN + "' expected"
      }
      if token != EXPR_ASSIGN {
        delete_grammar({ rules[:], symbols[:], {}, {} })
        return ---, "'" + EXPR_ASSIGN + "' expected"
      }
    }
    
    lhs := get_symbol(&symbols, token)
    nonlexemes[lhs] = {}
    symbols[lhs].type = type

    outer: for {
      rhs := make([dynamic]Symbol)

      for {
        code := parse_optional_code(&data)
        if code != {} {
          token := parse_token(&data)
          if token == EXPR_DONE || token == EXPR_ASSIGN {
            append(&rules, RuleDefinition { lhs, rhs[:], code })
            if token == EXPR_DONE do break outer
                                  continue outer
          }

          delete(rhs)
          delete_grammar({ rules[:], symbols[:], {}, {} })
          return ---, "'" + EXPR_ASSIGN + "' or '" + EXPR_DONE + "' expected"
        }

        token := parse_token(&data)

        if token == EXPR_DONE || token == EXPR_ASSIGN {
          append(&rules, RuleDefinition { lhs, rhs[:], code })
          if token == EXPR_DONE do break outer
                                continue outer
        }
        if token == CODE_OPEN {
          delete(rhs)
          delete_grammar({ rules[:], symbols[:], {}, {} })
          return ---, "'" + CODE_CLOSE + "' expected"
        }
        if token == "" || token == CODE_CLOSE {
          delete(rhs)
          delete_grammar({ rules[:], symbols[:], {}, {} })
          return ---, "rhs, '" + EXPR_ASSIGN + "', or '" + EXPR_DONE + "' expected"
        }

        append(&rhs, get_symbol(&symbols, token))
      }
    }
  }

  lexemes := make([]Symbol, len(symbols) - len(nonlexemes))
  i := 0
  for idx in 0..<len(symbols) {
    symbol := Symbol(idx)
    if !(symbol in nonlexemes) {
      lexemes[i] = symbol
      i += 1
    }
  }

  return {
    rules[:],
    symbols[:],
    lexemes,
    preamble,
  }, {}
}

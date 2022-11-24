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

Grammar :: struct {
  rules      : []RuleDefinition,
  enum_names : []string,
  symbols    : []string,
  lexemes    : []Symbol,
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
  for name in g.symbols[3:] {
    delete(name)
  }
  for name in g.enum_names[3:] {
    delete(name)
  }
  delete(g.rules)
  delete(g.symbols)
  delete(g.lexemes)
  delete(g.enum_names)
}

parse :: proc(d: []u8) -> (Grammar, Error) {
  rules      := make([dynamic]RuleDefinition)
  enum_names := make([dynamic]string)
  names      := make([dynamic]string)
  nonlexemes := make(map[Symbol]void)
  defer delete(nonlexemes)

  // append ROOT, EOF, and ERR symbols
  // the first symbol mentioned in the grammar file will be symbol 3
  rhs := make([]Symbol, 1)
  rhs[0] = Symbol(3)
  append(&rules, RuleDefinition { ROOT, rhs, {} })
  append(&names, "ROOT") // won't show up in templates but it's nice for debug information
  append(&names, "$")
  append(&names, "error")
  append(&enum_names, "")
  append(&enum_names, "EOF")
  append(&enum_names, "ERR")

  nonlexemes[ROOT] = {}

  get_symbol :: proc(names: ^[dynamic]string, enum_names: ^[dynamic]string, token: string) -> Symbol {
    name : string
    enum_name : string
    if token[0] == '"' && token[len(token) - 1] == '"' {
      name = strings.clone(token[1:len(token) - 1])
      enum_name = fmt.aprintf("_%i", len(enum_names))
    } else {
      name = strings.clone(token)
      enum_name = strings.clone(token)
    }
    for name2, idx in names {
      if name == name2 {
        delete(name)
        delete(enum_name)
        return Symbol(idx)
      }
    }
    append(names,      name)
    append(enum_names, enum_name)
    return Symbol(len(names) - 1)
  }

  parse_token :: proc(data: []u8) -> (string, []u8) {
    // skip whitespace
    start := 0
    a: for len(data) > start {
      switch data[start] {
        case '#':
          // code token
          if len(data) > start + 1 && data[start + 1] == '#' {
            return "##", data[start + 2:]
          }
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

    return transmute(string)data[start:end], data[end:]
  }

  data := d
  for {
    token, rest := parse_token(data)
    data = rest

    if token == "" do break
    if token == "." || token == "->" {
      delete_grammar({ rules[:], enum_names[:], names[:], {} })
      return ---, "lhs or EOF expected"
    }

    {
      token, rest := parse_token(data)
      data = rest
      if token != "->" {
        delete_grammar({ rules[:], enum_names[:], names[:], {} })
        return ---, "'->' expected"
      }
    }
    
    lhs := get_symbol(&names, &enum_names, token)
    rhs := make([dynamic]Symbol)

    nonlexemes[lhs] = {}

    for {
      token, rest := parse_token(data)
      data = rest

      if token == "." do break
      if token == "" || token == "->" {
        delete_grammar({ rules[:], enum_names[:], names[:], {} })
        return ---, "rhs or '.' expected"
      }
    
      append(&rhs, get_symbol(&names, &enum_names, token))
    }

    code := ""
    {
      token, rest := parse_token(data)
      if token == "##" {
        data = rest
        
        start := 0
        for len(data) > start + 1 && !(data[start] == '#' && data[start + 1] == '#') {
          start += 1
        }
        if len(data) > start + 1 && data[start] == '#' && data[start + 1] == '#' {
          code = strings.trim_space(transmute(string)data[:start])
          data = data[start + 2:]
        } else {
          return ---, "## expected"
        }
      }
    }

    append(&rules, RuleDefinition { lhs, rhs[:], code })
  }

  lexemes := make([]Symbol, len(names) - len(nonlexemes))
  i := 0
  for idx in 0..<len(names) {
    symbol := Symbol(idx)
    if !(symbol in nonlexemes) {
      lexemes[i] = symbol
      i += 1
    }
  }

  return {
    rules[:],
    enum_names[:],
    names[:],
    lexemes,
  }, {}
}

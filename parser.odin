package main

import "core:strings"
import "core:fmt"

Symbol :: distinct int
Lexeme :: distinct u8

Rule  :: distinct int
START :: Rule(0)

RuleDefinition :: struct {
  lhs : Symbol,
  rhs : []Symbol,
}

Grammar :: struct {
  rules   : []RuleDefinition,
  symbols : []string,
  lexemes : []Symbol,
}

ROOT :: Symbol(0)
EOF  :: Lexeme(0)

void :: struct{}

parse :: proc(d : []u8) -> (Grammar, bool) {
  rules      := make([dynamic]RuleDefinition)
  names      := make([dynamic]string)
  nonlexemes := make(map[Symbol]void)
  defer delete(nonlexemes)

  // append ROOT and EOF symbols
  // the first symbol mentioned in the grammar file will be symbol 2
  rhs := make([]Symbol, 1)
  rhs[0] = Symbol(2)
  append(&rules, RuleDefinition { ROOT, rhs })
  append(&names, "ROOT")
  append(&names, "EOF")

  nonlexemes[ROOT] = {}

  get_symbol :: proc(names : ^[dynamic]string, token : string) -> Symbol {
    for name, idx in names {
      if token == name {
        return Symbol(idx)
      }
    }
    append(names, strings.clone(token))
    return Symbol(len(names) - 1)
  }

  parse_token :: proc(data : []u8) -> (string, []u8) {
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

    return transmute(string)data[start:end], data[end:]
  }

  data := d
  for {
    token, rest := parse_token(data)
    data = rest

    if token == ""                   do break
    if token == "." || token == "->" do panic("lhs or EOF expected")

    {
      token, rest := parse_token(data)
      data = rest
      if token != "->" do panic("'->' expected")
    }
    
    lhs := get_symbol(&names, token)
    rhs := make([dynamic]Symbol)

    nonlexemes[lhs] = {}

    for {
      token, rest := parse_token(data)
      data = rest

      if token == "."                 do break
      if token == "" || token == "->" do panic("rhs or '.' expected")
    
      append(&rhs, get_symbol(&names, token))
    }

    append(&rules, RuleDefinition { lhs, rhs[:] })
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
    names[:],
    lexemes,
  }, true
}

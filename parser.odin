package main

import "core:strings"
import "core:fmt"

symbol :: distinct u8

rule :: struct {
  lhs : symbol,
  rhs : []symbol,
}

grammar :: struct {
  rules : []rule,
  names : []string,
}

parse :: proc(d : []u8) -> (grammar, bool) {
  rules := make([dynamic]rule)
  names := make([dynamic]string)

  get_symbol :: proc(names : ^[dynamic]string, token : string) -> symbol {
    for name, idx in names {
      if token == name {
        return symbol(idx)
      }
    }
    append(names, strings.clone(token))
    return symbol(len(names) - 1)
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
    rhs := make([dynamic]symbol)

    for {
      token, rest := parse_token(data)
      data = rest

      if token == "."                 do break
      if token == "" || token == "->" do panic("rhs or '.' expected")
    
      append(&rhs, get_symbol(&names, token))
    }

    append(&rules, rule { lhs, rhs[:] })
  }

  return {
    rules[:],
    names[:],
  }, true
}

#pragma once

#include <stdbool.h>

#include "stack.h"

//preamble
//l ${preamble}

//e
typedef enum { SYMBOL_EOF, SYMBOL_ERR } parser_symbol; //d
//l typedef enum {
//symbol
  //w  SYMBOL_${symbol.enum}
  //s ,
//e
//w  } parser_symbol;

const char *parser_symbol_name(parser_symbol symbol);
      bool  parser_parse      (struct stack_s lexemes); //d
//l       bool  parser_parse      (struct stack_s lexemes
//rule.0.lhs.type
  //w , ${type} *value
//e
//w );


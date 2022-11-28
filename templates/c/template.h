#pragma once
#include <stdbool.h>

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

typedef struct {
  parser_symbol symbol;
  void         *value;
} parser_value;

const char *parser_symbol_name(parser_symbol symbol);
      bool  parser_parse      (parser_value *lexemes); //d
//l       bool  parser_parse      (parser_value *lexemes
//rule.0.lhs.type
  //w , ${type} *value
//e
//w );


#include "parser.h"

const char *parser_symbol_name(parser_symbol symbol) {
  switch (symbol) {
    case SYMBOL_EOF: return "EOF"; //d
    case SYMBOL_ERR: return "ERR"; //d
  //symbol
    //l case SYMBOL_${symbol.enum}: return "${symbol.name}";
  //e
  }
  return "";
}

bool parser_parse(struct stack_s symbols) { //d
//l bool parser_parse(struct stack_s symbols
//rule.0.lhs.type
  //w , ${type} *value
//e
//w ) {
  struct stack_s shifted = stack_make(16);

  int state = 0;

  while (true) {
    parser_symbol next = stack_peek(symbols, parser_symbol);

    #define POP()\
      stack_pop(shifted, int)
    #define POP_CHILD(type, index)\
      POP(); type _##index = stack_pop(shifted, type)
    #define SHIFT_PUSH(newstate, type)\
      stack_pop(symbols, parser_symbol);\
      _stack_push(&shifted, sizeof(type), _stack_pop(&symbols, sizeof(type)));\
      stack_push(shifted, state);\
      state = newstate
    #define SHIFT(newstate)\
      stack_pop(symbols, parser_symbol);\
      stack_push(shifted, state);\
      state = newstate
    #define REDUCE(symbol)\
      parser_symbol sym = SYMBOL_##symbol;\
      stack_push(symbols, sym)

    switch (state) {
    //state
      //l case ${state.index}:
      //l {
        switch (next) {
      //state.lookahead lah
        //lah.accept
          //lah.symbol
          //l case SYMBOL_${symbol.enum}:
          //e
          //l {
          //rule.0.lhs.type
            //l POP_CHILD(${type}, 0);
            //l *value = _0;
          //e
          //l   stack_destroy(shifted);
          //l   return true;
          //l }
        //e
        //lah.shift
          //lah.symbol
          //l case SYMBOL_${symbol.enum}:
          //l {
            //l SHIFT
          //symbol.type
            //w _PUSH
          //e
            //w (${shift}
          //symbol.type
            //w , ${type}
          //e
            //w );
          //l   continue;
          //l }
          //e
        //e
        //lah.reduce
          //lah.symbol
          //l case SYMBOL_${symbol.enum}:
          //e
          //l {
          //reduce.lhs.type
           //l
            //reduce.rhs.reversed child _ index
                //f  state =
                //w  POP
              //child.type
                //w _CHILD
              //e
                //w (
              //child.type
                //w ${type}, ${index}
              //e
                //w );
            //e
            //l ${type} this;
            //reduce.code
              //w  ${code}
            //e
            //l stack_push(symbols, this);
          //e
          //l   REDUCE(${reduce.lhs.enum});
          //l   continue;
          //l }
        //e
      //e
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      //l }
    //e
    }
  }
}


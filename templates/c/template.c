#include "template.h" //d
//l #include "parser.h"

#include "array.h"

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

typedef struct {
  parser_symbol symbol;
  void *value;
  int state;
} parser_state;

void *duplicate(void *ptr, size_t size) {
  void *dup = malloc(size);
  memcpy(dup, ptr, size);
  return dup;
}

bool parser_parse(parser_value *lexemes) { //d
//l bool parser_parse(parser_value *lexemes
//rule.0.lhs.type
  //w , ${type} *value
//e
//w ) {
  struct array_s stack   = array_make(parser_value, 16);
  struct array_s shifted = array_make(parser_state, 16);

  int state = 0;

  while (true) {
    parser_value next;
    if (stack.length == 0) {
      next = *lexemes;
    } else {
      next = array_peek(stack, parser_value);
    }

    #define CHILD(type, len, index)\
      void* _v##index = array_elem(shifted, parser_state, shifted.length - len + index).value;\
      type _##index = *(type*)_v##index;\
      free(_v##index);
    #define shift(newstate) do {\
      if (stack.length > 0) stack.length--; else if (next.symbol != SYMBOL_EOF) lexemes++;\
      array_push(shifted, ((parser_state){ next.symbol, next.value, state }));\
      state = newstate;\
    } while(0)
    #define reduce(len, symbol, value) do {\
      shifted.length -= len;\
      state = array_elem(shifted, parser_state, shifted.length).state;\
      array_push(stack, ((parser_value){ symbol, value }));\
    } while(0)
    #define dup(value) duplicate(&value, sizeof(value))

    switch (state) {
    //state
      //l case ${state.index}:
      //l {
        switch (next.symbol) {
      //state.lookahead lah
        //lah.symbol
          //l case SYMBOL_${symbol.enum}:
        //e
        //l   {
        //lah.accept
          //rule.0.lhs.type
            //l CHILD(${type}, 1, 0)
            //l *value = _0;
          //e
          //l   return true;
        //e
        //lah.shift
          //l   shift(${shift});
          //l   continue;
        //e
        //lah.reduce
          //reduce.lhs.type
            //l ${type} this;
            //reduce.rhs child index
              //child.type
                //w  CHILD(${type}, ${reduce.rhs.length}, ${index})
              //e
            //e
            //reduce.code
            //l ${code}
            //e
          //e
          //l   void *value
          //reduce.lhs.type
            //w  = dup(this)
          //e
          //w ;
          //l   reduce(${reduce.rhs.length}, SYMBOL_${reduce.lhs.enum}, value);
          //l   continue;
        //e
        //l   }
      //e
          default:
            return false;
        }
      //l }
    //e
    }
  }
}


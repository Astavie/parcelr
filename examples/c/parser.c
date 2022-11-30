#include "parser.h"

const char *parser_symbol_name(parser_symbol symbol) {
  switch (symbol) {
    case SYMBOL_EOF: return "$";
    case SYMBOL_ERR: return "error";
    case SYMBOL_number: return "number";
    case SYMBOL_string: return "string";
    case SYMBOL_value: return "value";
    case SYMBOL_object: return "object";
    case SYMBOL_array: return "array";
    case SYMBOL_TRUE: return "true";
    case SYMBOL_FALSE: return "false";
    case SYMBOL_NULL: return "null";
    case SYMBOL_OPEN_BRACE: return "{";
    case SYMBOL_CLOSE_BRACE: return "}";
    case SYMBOL_members: return "members";
    case SYMBOL_member: return "member";
    case SYMBOL_COMMA: return ",";
    case SYMBOL_COLON: return ":";
    case SYMBOL_OPEN_BRACKET: return "[";
    case SYMBOL_CLOSE_BRACKET: return "]";
    case SYMBOL_values: return "values";
  }
  return "";
}

bool parser_parse(struct stack_s symbols, json_value *value) {
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
      case 0:
      {
        switch (next) {
          case SYMBOL_value:
          {
            SHIFT_PUSH(1, json_value);
            continue;
          }
          case SYMBOL_object:
          {
            SHIFT_PUSH(2, json_object);
            continue;
          }
          case SYMBOL_array:
          {
            SHIFT_PUSH(3, json_array);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(4, json_string);
            continue;
          }
          case SYMBOL_number:
          {
            SHIFT_PUSH(5, double);
            continue;
          }
          case SYMBOL_TRUE:
          {
            SHIFT(6);
            continue;
          }
          case SYMBOL_FALSE:
          {
            SHIFT(7);
            continue;
          }
          case SYMBOL_NULL:
          {
            SHIFT(8);
            continue;
          }
          case SYMBOL_OPEN_BRACKET:
          {
            SHIFT(9);
            continue;
          }
          case SYMBOL_OPEN_BRACE:
          {
            SHIFT(10);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 1:
      {
        switch (next) {
          case SYMBOL_EOF:
          {
            POP_CHILD(json_value, 0);
            *value = _0;
            stack_destroy(shifted);
            return true;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 2:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP_CHILD(json_object, 0);
            json_value this; this.type = JSON_OBJECT; this.data.object = _0;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 3:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP_CHILD(json_array, 0);
            json_value this; this.type = JSON_ARRAY;  this.data.array  = _0;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 4:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP_CHILD(json_string, 0);
            json_value this; this.type = JSON_STRING; this.data.string = _0;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 5:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP_CHILD(double, 0);
            json_value this; this.type = JSON_NUMBER; this.data.number = _0;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 6:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP();
            json_value this; this.type = JSON_BOOL; this.data.boolean = true;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 7:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP();
            json_value this; this.type = JSON_BOOL; this.data.boolean = false;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 8:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            state = POP();
            json_value this; this.type = JSON_NULL;
            stack_push(symbols, this);
            REDUCE(value);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 9:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACKET:
          {
            SHIFT(11);
            continue;
          }
          case SYMBOL_values:
          {
            SHIFT_PUSH(12, json_array);
            continue;
          }
          case SYMBOL_value:
          {
            SHIFT_PUSH(13, json_value);
            continue;
          }
          case SYMBOL_object:
          {
            SHIFT_PUSH(2, json_object);
            continue;
          }
          case SYMBOL_array:
          {
            SHIFT_PUSH(3, json_array);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(4, json_string);
            continue;
          }
          case SYMBOL_number:
          {
            SHIFT_PUSH(5, double);
            continue;
          }
          case SYMBOL_TRUE:
          {
            SHIFT(6);
            continue;
          }
          case SYMBOL_FALSE:
          {
            SHIFT(7);
            continue;
          }
          case SYMBOL_NULL:
          {
            SHIFT(8);
            continue;
          }
          case SYMBOL_OPEN_BRACKET:
          {
            SHIFT(9);
            continue;
          }
          case SYMBOL_OPEN_BRACE:
          {
            SHIFT(10);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 10:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACE:
          {
            SHIFT(14);
            continue;
          }
          case SYMBOL_members:
          {
            SHIFT_PUSH(15, json_object);
            continue;
          }
          case SYMBOL_member:
          {
            SHIFT_PUSH(16, json_entry);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(17, json_string);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 11:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            POP(); state = POP();
            json_array this; this = (json_array){0};
            stack_push(symbols, this);
            REDUCE(array);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 12:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACKET:
          {
            SHIFT(18);
            continue;
          }
          case SYMBOL_COMMA:
          {
            SHIFT(19);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 13:
      {
        switch (next) {
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          {
            state = POP_CHILD(json_value, 0);
            json_array this; this = array_make(json_value, 16); array_push(this, _0);
            stack_push(symbols, this);
            REDUCE(values);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 14:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            POP(); state = POP();
            json_object this; this = (json_object){0};
            stack_push(symbols, this);
            REDUCE(object);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 15:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACE:
          {
            SHIFT(20);
            continue;
          }
          case SYMBOL_COMMA:
          {
            SHIFT(21);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 16:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACE:
          case SYMBOL_COMMA:
          {
            state = POP_CHILD(json_entry, 0);
            json_object this; hashmap_create(16, &this); hashmap_put(&this, _0.key.string, _0.key.length, alloc_clone(_0.value));
            stack_push(symbols, this);
            REDUCE(members);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 17:
      {
        switch (next) {
          case SYMBOL_COLON:
          {
            SHIFT(22);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 18:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            POP(); POP_CHILD(json_array, 1); state = POP();
            json_array this; this = _1;
            stack_push(symbols, this);
            REDUCE(array);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 19:
      {
        switch (next) {
          case SYMBOL_value:
          {
            SHIFT_PUSH(23, json_value);
            continue;
          }
          case SYMBOL_object:
          {
            SHIFT_PUSH(2, json_object);
            continue;
          }
          case SYMBOL_array:
          {
            SHIFT_PUSH(3, json_array);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(4, json_string);
            continue;
          }
          case SYMBOL_number:
          {
            SHIFT_PUSH(5, double);
            continue;
          }
          case SYMBOL_TRUE:
          {
            SHIFT(6);
            continue;
          }
          case SYMBOL_FALSE:
          {
            SHIFT(7);
            continue;
          }
          case SYMBOL_NULL:
          {
            SHIFT(8);
            continue;
          }
          case SYMBOL_OPEN_BRACKET:
          {
            SHIFT(9);
            continue;
          }
          case SYMBOL_OPEN_BRACE:
          {
            SHIFT(10);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 20:
      {
        switch (next) {
          case SYMBOL_EOF:
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          case SYMBOL_CLOSE_BRACE:
          {
            POP(); POP_CHILD(json_object, 1); state = POP();
            json_object this; this = _1;
            stack_push(symbols, this);
            REDUCE(object);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 21:
      {
        switch (next) {
          case SYMBOL_member:
          {
            SHIFT_PUSH(24, json_entry);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(17, json_string);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 22:
      {
        switch (next) {
          case SYMBOL_value:
          {
            SHIFT_PUSH(25, json_value);
            continue;
          }
          case SYMBOL_object:
          {
            SHIFT_PUSH(2, json_object);
            continue;
          }
          case SYMBOL_array:
          {
            SHIFT_PUSH(3, json_array);
            continue;
          }
          case SYMBOL_string:
          {
            SHIFT_PUSH(4, json_string);
            continue;
          }
          case SYMBOL_number:
          {
            SHIFT_PUSH(5, double);
            continue;
          }
          case SYMBOL_TRUE:
          {
            SHIFT(6);
            continue;
          }
          case SYMBOL_FALSE:
          {
            SHIFT(7);
            continue;
          }
          case SYMBOL_NULL:
          {
            SHIFT(8);
            continue;
          }
          case SYMBOL_OPEN_BRACKET:
          {
            SHIFT(9);
            continue;
          }
          case SYMBOL_OPEN_BRACE:
          {
            SHIFT(10);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 23:
      {
        switch (next) {
          case SYMBOL_COMMA:
          case SYMBOL_CLOSE_BRACKET:
          {
            POP_CHILD(json_value, 2); POP(); state = POP_CHILD(json_array, 0);
            json_array this; this = _0; array_push(this, _2);
            stack_push(symbols, this);
            REDUCE(values);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 24:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACE:
          case SYMBOL_COMMA:
          {
            POP_CHILD(json_entry, 2); POP(); state = POP_CHILD(json_object, 0);
            json_object this; this = _0; hashmap_put(&this, _2.key.string, _2.key.length, alloc_clone(_2.value));
            stack_push(symbols, this);
            REDUCE(members);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
      case 25:
      {
        switch (next) {
          case SYMBOL_CLOSE_BRACE:
          case SYMBOL_COMMA:
          {
            POP_CHILD(json_value, 2); POP(); state = POP_CHILD(json_string, 0);
            json_entry this; this = (json_entry){ _0, _2 };
            stack_push(symbols, this);
            REDUCE(member);
            continue;
          }
          default:
          {
            stack_destroy(shifted);
            return false;
          }
        }
      }
    }
  }
}


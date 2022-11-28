#include "parser.h"

#include "array.h"

const char *parser_symbol_name(parser_symbol symbol) {
  switch (symbol) {
    case SYMBOL_EOF: return "$";
    case SYMBOL_ERR: return "error";
    case SYMBOL_number: return "number";
    case SYMBOL_string: return "string";
    case SYMBOL_value: return "value";
    case SYMBOL_object: return "object";
    case SYMBOL_array: return "array";
    case SYMBOL__8: return "true";
    case SYMBOL__9: return "false";
    case SYMBOL__10: return "null";
    case SYMBOL__11: return "{";
    case SYMBOL__12: return "}";
    case SYMBOL_members: return "members";
    case SYMBOL_member: return "member";
    case SYMBOL__15: return ",";
    case SYMBOL__16: return ":";
    case SYMBOL__17: return "[";
    case SYMBOL__18: return "]";
    case SYMBOL_values: return "values";
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

bool parser_parse(parser_value *lexemes, json_value *value) {
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
      case 0:
      {
        switch (next.symbol) {
          case SYMBOL_value:
          {
            shift(1);
            continue;
          }
          case SYMBOL_object:
          {
            shift(2);
            continue;
          }
          case SYMBOL_array:
          {
            shift(3);
            continue;
          }
          case SYMBOL_string:
          {
            shift(4);
            continue;
          }
          case SYMBOL_number:
          {
            shift(5);
            continue;
          }
          case SYMBOL__8:
          {
            shift(6);
            continue;
          }
          case SYMBOL__9:
          {
            shift(7);
            continue;
          }
          case SYMBOL__10:
          {
            shift(8);
            continue;
          }
          case SYMBOL__17:
          {
            shift(9);
            continue;
          }
          case SYMBOL__11:
          {
            shift(10);
            continue;
          }
          default:
            return false;
        }
      }
      case 1:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          {
            CHILD(json_value, 1, 0)
            *value = _0;
            return true;
          }
          default:
            return false;
        }
      }
      case 2:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this; CHILD(json_object, 1, 0)
            this.type = JSON_OBJECT; this.data.object = _0;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 3:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this; CHILD(json_array, 1, 0)
            this.type = JSON_ARRAY; this.data.array = _0;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 4:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this; CHILD(json_string, 1, 0)
            this.type = JSON_STRING; this.data.string = _0;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 5:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this; CHILD(double, 1, 0)
            this.type = JSON_NUMBER; this.data.number = _0;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 6:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this;
            this.type = JSON_BOOL; this.data.boolean = true;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 7:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this;
            this.type = JSON_BOOL; this.data.boolean = false;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 8:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_value this;
            this.type = JSON_NULL;
            void *value = dup(this);
            reduce(1, SYMBOL_value, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 9:
      {
        switch (next.symbol) {
          case SYMBOL__18:
          {
            shift(11);
            continue;
          }
          case SYMBOL_values:
          {
            shift(12);
            continue;
          }
          case SYMBOL_value:
          {
            shift(13);
            continue;
          }
          case SYMBOL_object:
          {
            shift(2);
            continue;
          }
          case SYMBOL_array:
          {
            shift(3);
            continue;
          }
          case SYMBOL_string:
          {
            shift(4);
            continue;
          }
          case SYMBOL_number:
          {
            shift(5);
            continue;
          }
          case SYMBOL__8:
          {
            shift(6);
            continue;
          }
          case SYMBOL__9:
          {
            shift(7);
            continue;
          }
          case SYMBOL__10:
          {
            shift(8);
            continue;
          }
          case SYMBOL__17:
          {
            shift(9);
            continue;
          }
          case SYMBOL__11:
          {
            shift(10);
            continue;
          }
          default:
            return false;
        }
      }
      case 10:
      {
        switch (next.symbol) {
          case SYMBOL__12:
          {
            shift(14);
            continue;
          }
          case SYMBOL_members:
          {
            shift(15);
            continue;
          }
          case SYMBOL_member:
          {
            shift(16);
            continue;
          }
          case SYMBOL_string:
          {
            shift(17);
            continue;
          }
          default:
            return false;
        }
      }
      case 11:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_array this;
            this = (json_array){0};
            void *value = dup(this);
            reduce(2, SYMBOL_array, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 12:
      {
        switch (next.symbol) {
          case SYMBOL__18:
          {
            shift(18);
            continue;
          }
          case SYMBOL__15:
          {
            shift(19);
            continue;
          }
          default:
            return false;
        }
      }
      case 13:
      {
        switch (next.symbol) {
          case SYMBOL__15:
          case SYMBOL__18:
          {
            json_array this; CHILD(json_value, 1, 0)
            this = array_make(json_value, 16); array_push(this, _0);
            void *value = dup(this);
            reduce(1, SYMBOL_values, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 14:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_object this;
            this = (json_object){0};
            void *value = dup(this);
            reduce(2, SYMBOL_object, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 15:
      {
        switch (next.symbol) {
          case SYMBOL__12:
          {
            shift(20);
            continue;
          }
          case SYMBOL__15:
          {
            shift(21);
            continue;
          }
          default:
            return false;
        }
      }
      case 16:
      {
        switch (next.symbol) {
          case SYMBOL__12:
          case SYMBOL__15:
          {
            json_object this; CHILD(json_entry, 1, 0)
            hashmap_create(16, &this); hashmap_put(&this, _0.key.string, _0.key.length, dup(_0.value));
            void *value = dup(this);
            reduce(1, SYMBOL_members, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 17:
      {
        switch (next.symbol) {
          case SYMBOL__16:
          {
            shift(22);
            continue;
          }
          default:
            return false;
        }
      }
      case 18:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_array this; CHILD(json_array, 3, 1)
            this = _1;
            void *value = dup(this);
            reduce(3, SYMBOL_array, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 19:
      {
        switch (next.symbol) {
          case SYMBOL_value:
          {
            shift(23);
            continue;
          }
          case SYMBOL_object:
          {
            shift(2);
            continue;
          }
          case SYMBOL_array:
          {
            shift(3);
            continue;
          }
          case SYMBOL_string:
          {
            shift(4);
            continue;
          }
          case SYMBOL_number:
          {
            shift(5);
            continue;
          }
          case SYMBOL__8:
          {
            shift(6);
            continue;
          }
          case SYMBOL__9:
          {
            shift(7);
            continue;
          }
          case SYMBOL__10:
          {
            shift(8);
            continue;
          }
          case SYMBOL__17:
          {
            shift(9);
            continue;
          }
          case SYMBOL__11:
          {
            shift(10);
            continue;
          }
          default:
            return false;
        }
      }
      case 20:
      {
        switch (next.symbol) {
          case SYMBOL_EOF:
          case SYMBOL__15:
          case SYMBOL__18:
          case SYMBOL__12:
          {
            json_object this; CHILD(json_object, 3, 1)
            this = _1;
            void *value = dup(this);
            reduce(3, SYMBOL_object, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 21:
      {
        switch (next.symbol) {
          case SYMBOL_member:
          {
            shift(24);
            continue;
          }
          case SYMBOL_string:
          {
            shift(17);
            continue;
          }
          default:
            return false;
        }
      }
      case 22:
      {
        switch (next.symbol) {
          case SYMBOL_value:
          {
            shift(25);
            continue;
          }
          case SYMBOL_object:
          {
            shift(2);
            continue;
          }
          case SYMBOL_array:
          {
            shift(3);
            continue;
          }
          case SYMBOL_string:
          {
            shift(4);
            continue;
          }
          case SYMBOL_number:
          {
            shift(5);
            continue;
          }
          case SYMBOL__8:
          {
            shift(6);
            continue;
          }
          case SYMBOL__9:
          {
            shift(7);
            continue;
          }
          case SYMBOL__10:
          {
            shift(8);
            continue;
          }
          case SYMBOL__17:
          {
            shift(9);
            continue;
          }
          case SYMBOL__11:
          {
            shift(10);
            continue;
          }
          default:
            return false;
        }
      }
      case 23:
      {
        switch (next.symbol) {
          case SYMBOL__15:
          case SYMBOL__18:
          {
            json_array this; CHILD(json_array, 3, 0) CHILD(json_value, 3, 2)
            this = _0; array_push(this, _2);
            void *value = dup(this);
            reduce(3, SYMBOL_values, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 24:
      {
        switch (next.symbol) {
          case SYMBOL__12:
          case SYMBOL__15:
          {
            json_object this; CHILD(json_object, 3, 0) CHILD(json_entry, 3, 2)
            this = _0; hashmap_put(&this, _2.key.string, _2.key.length, dup(_2.value));
            void *value = dup(this);
            reduce(3, SYMBOL_members, value);
            continue;
          }
          default:
            return false;
        }
      }
      case 25:
      {
        switch (next.symbol) {
          case SYMBOL__12:
          case SYMBOL__15:
          {
            json_entry this; CHILD(json_string, 3, 0) CHILD(json_value, 3, 2)
            this = (json_entry){ _0, _2 };
            void *value = dup(this);
            reduce(3, SYMBOL_member, value);
            continue;
          }
          default:
            return false;
        }
      }
    }
  }
}


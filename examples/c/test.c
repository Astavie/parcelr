#include <stdio.h>

#include "parser.h"

void print(json_value value, int indent);

typedef struct {
  int indent;
  bool first;
} ctx;

int print_elem(void* const context, struct hashmap_element_s* const e) {
  int indent = ((ctx*)context)->indent;
  bool first = ((ctx*)context)->first;
  if (first) ((ctx*)context)->first = false;
  printf("%*s%.*s: ", first ? 0 : indent, "", e->key_len, e->key);

  json_type type = (*(json_value*)e->data).type;
  if (type == JSON_ARRAY) {
    printf("\n%*s", indent, "");
  } else if (type == JSON_OBJECT) {
    printf("\n%*s", indent + 2, "");
  }

  print(*(json_value*)e->data, indent + 2);
  return 0;
}

void print(json_value value, int indent) {
  switch (value.type) {
    case JSON_NULL:
    {
      printf("null\n");
      break;
    }
    case JSON_STRING:
    {
      printf("%.*s\n", value.data.string.length, value.data.string.string);
      break;
    }
    case JSON_NUMBER:
    {
      printf("%f\n", value.data.number);
      break;
    }
    case JSON_BOOL:
    {
      if (value.data.boolean) printf("true\n");
      else                    printf("false\n");
      break;
    }
    case JSON_ARRAY:
    {
      json_array array = value.data.array;
      for (int i = 0; i < array.length; i++) {
        printf("%*s", i == 0 ? 0 : indent, "- ");
        json_value val = array_elem(array, json_value, i);
        print(val, val.type == JSON_OBJECT ? indent : indent + 2);
      }
      break;
    }
    case JSON_OBJECT:
    {
      ctx context = { indent, true };
      hashmap_iterate_pairs(&value.data.object, print_elem, &context);
      break;
    }
  }
}

bool prefix(const char *pre, char *str, unsigned long *i)
{
  unsigned long len = strlen(pre);
  if (strncmp(pre, str + *i - len + 1, len) == 0) {
    *i -= len - 1;
    return true;
  }
  return false;
}

int main(int argc, char **argv) {
  struct stack_s values = stack_make(16);
 
  parser_symbol eof = SYMBOL_EOF;
  stack_push(values, eof);

  for (int j = argc - 1; j > 0; j--) {
    char *text = argv[j];
    unsigned long len = strlen(text);
    unsigned long i = len;

  end:
    while (i > 0) {
      i--;

      #define SYM(symbol) parser_symbol sym = SYMBOL_##symbol; stack_push(values, sym);
      #define VAL(symbol) stack_push(values, symbol); SYM(symbol)

      while (text[i] == ' ' || text[i] == '\t' || text[i] == '\n' || text[i] == '\v' || text[i] == '\f' || text[i] == '\r') {
        if (i == 0) goto end;
        i--;
      }

      if (prefix("true", text, &i)) {
        SYM(_8);
        continue;
      }
      if (prefix("false", text, &i)) {
        SYM(_9);
        continue;
      }
      if (prefix("null", text, &i)) {
        SYM(_10);
        continue;
      }
      if (text[i] == '{') {
        SYM(_11);
        continue;
      }
      if (text[i] == '}') {
        SYM(_12);
        continue;
      }
      if (text[i] == ',') {
        SYM(_15);
        continue;
      }
      if (text[i] == ':') {
        SYM(_16);
        continue;
      }
      if (text[i] == '[') {
        SYM(_17);
        continue;
      }
      if (text[i] == ']') {
        SYM(_18);
        continue;
      }
      if (text[i] == '"') {
        int length = 0;
        while (length < i && text[i - 1 - length] != '"') length++;
        if (length == i) return 1;

        json_string string = { &text[i - length], length };
        VAL(string);

        i -= length + 1;
        continue;
      }

      char *next = &text[i];
      double number = strtod(&text[i], &next);
      if (next == &text[i]) return 1;

      while (i > 0) {
        char *next = &text[i - 1];
        double n = strtod(&text[i - 1], &next);
        if (next == &text[i - 1]) break;

        i--;
        number = n;
      }

      VAL(number);
    }
  }
 
  json_value value = {0};
  parser_parse(values, &value);
  print(value, 0);
}

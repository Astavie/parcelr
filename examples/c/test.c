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

bool prefix(const char *pre, char **str)
{
  if (strncmp(pre, *str, strlen(pre)) == 0) {
    *str += strlen(pre);
    return true;
  }
  return false;
}

int main(int argc, char **argv) {
  struct array_s values = array_make(parser_value, 16);
 
  for (int i = 1; i < argc; i++) {
    char *current = argv[i];

    while (current[0] != 0) {
      #define sym(symbol) array_push(values, ((parser_value){ SYMBOL_##symbol, NULL }))
      #define val(symbol) array_push(values, ((parser_value){ SYMBOL_##symbol, symbol }))

      while (current[0] == ' ' || current[0] == '\t' || current[0] == '\n' || current[0] == '\v' || current[0] == '\f' || current[0] == '\r') {
        current++;
        if (current[0] == 0) break;
      }

      if (prefix("true", &current)) {
        sym(_8);
        continue;
      }
      if (prefix("false", &current)) {
        sym(_9);
        continue;
      }
      if (prefix("null", &current)) {
        sym(_10);
        continue;
      }
      if (current[0] == '{') {
        current++;
        sym(_11);
        continue;
      }
      if (current[0] == '}') {
        current++;
        sym(_12);
        continue;
      }
      if (current[0] == ',') {
        current++;
        sym(_15);
        continue;
      }
      if (current[0] == ':') {
        current++;
        sym(_16);
        continue;
      }
      if (current[0] == '[') {
        current++;
        sym(_17);
        continue;
      }
      if (current[0] == ']') {
        current++;
        sym(_18);
        continue;
      }
      if (current[0] == '"') {
        current++;

        int length = 0;
        while (current[length] != 0 && current[length] != '"') length++;
        if (current[length] == 0) return 1;

        json_string *string = (json_string*)malloc(sizeof(json_string));
        string->string = current;
        string->length = length;
        val(string);

        current += length + 1;
        continue;
      }

      char *next = current;
      double f = strtod(current, &next);

      if (next == current) return 1;
      current = next;

      double *number = (double*)malloc(sizeof(double));
      *number = f;
      val(number);
    }
  }

  array_push(values, ((parser_value){ SYMBOL_EOF, NULL }));
 
  json_value value = {0};
  parser_parse((parser_value*)values.data, &value);
  print(value, 0);
}

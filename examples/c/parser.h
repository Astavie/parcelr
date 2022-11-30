#pragma once

#include <stdbool.h>

#include "stack.h"

#include "array.h"
#include "hashmap.h"

typedef struct {
  const char *string;
  unsigned length;
} json_string;

typedef struct hashmap_s json_object;
typedef struct array_s json_array;

typedef enum {
  JSON_NULL, JSON_OBJECT, JSON_ARRAY, JSON_STRING, JSON_NUMBER, JSON_BOOL
} json_type;

typedef struct {
  json_type type;
  union {
    json_object object;
    json_array array;
    json_string string;
    double number;
    bool boolean;
  } data;
} json_value;

typedef struct {
  json_string key;
  json_value value;
} json_entry;

static void *duplicate(void *ptr, size_t size) {
  void *dup = malloc(size);
  memcpy(dup, ptr, size);
  return dup;
}

#define dup(value) duplicate(&value, sizeof(value))

typedef enum { SYMBOL_EOF, SYMBOL_ERR, SYMBOL_number, SYMBOL_string, SYMBOL_value, SYMBOL_object, SYMBOL_array, SYMBOL__8, SYMBOL__9, SYMBOL__10, SYMBOL__11, SYMBOL__12, SYMBOL_members, SYMBOL_member, SYMBOL__15, SYMBOL__16, SYMBOL__17, SYMBOL__18, SYMBOL_values } parser_symbol;

const char *parser_symbol_name(parser_symbol symbol);
      bool  parser_parse      (struct stack_s lexemes, json_value *value);

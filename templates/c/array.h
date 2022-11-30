#pragma once

#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

struct array_s {
  char    *data;
  unsigned length;
  unsigned _capacity;
};

#define array_make(type, length) ((struct array_s){(char*)malloc(sizeof(type) * length), 0, length})

static void array_destroy(struct array_s array) {
  free(array.data);
  array.length = 0;
  array._capacity = 0;
}

static void _array_resize(struct array_s *array, size_t size, unsigned length) {
  char *newdata = (char*)malloc(size * length);
  memcpy(newdata, array->data, size * length);

  free(array->data);
  array->data = newdata;
  array->_capacity = length;
}

#define array_push(array, elem) _array_push(&array, sizeof(elem), &elem)

static void _array_push(struct array_s *array, size_t size, void *data) {
  if (array->length == array->_capacity) {
    _array_resize(array, size, array->_capacity * 2);
  }
  memcpy(array->data + array->length * size, data, size);
  array->length++;
}

#define array_elem(array, type, index) (((type*)(array.data))[index])

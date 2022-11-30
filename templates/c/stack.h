#pragma once

#include <stddef.h>
#include <stdlib.h>
#include <string.h>

struct stack_s {
  size_t  *data;
  unsigned length;
  unsigned _capacity;
};

#define stack_make(length) ((struct stack_s){(size_t*)malloc(sizeof(size_t) * length), 0, length})

static void stack_destroy(struct stack_s stack) {
  free(stack.data);
  stack.length = 0;
  stack._capacity = 0;
}

static void _stack_resize(struct stack_s *stack, unsigned length) {
  size_t* newdata = (size_t*)malloc(sizeof(size_t) * length);
  memcpy(newdata, stack->data, sizeof(size_t) * length);

  free(stack->data);
  stack->data = newdata;
  stack->_capacity = length;
}

#define stack_push(stack, elem) _stack_push(&stack, sizeof(elem), &elem)

static void _stack_push(struct stack_s *stack, size_t size, void *data) {
  unsigned length = (size - 1) / sizeof(size_t) + 1;
  unsigned newcap = stack->_capacity;
  while (stack->length + length > newcap) newcap *= 2;

  if (newcap > stack->_capacity) {
    _stack_resize(stack, newcap);
  }

  memcpy(&stack->data[stack->length], data, length * sizeof(size_t));
  stack->length += length;
}

#define stack_pop(stack, type) (*(type*)_stack_pop(&stack, sizeof(type)))
#define stack_peek(stack, type) (*(type*)_stack_peek(stack, sizeof(type)))

static void *_stack_pop(struct stack_s *stack, size_t size) {
  unsigned length = (size - 1) / sizeof(size_t) + 1;
  stack->length -= length;
  return &stack->data[stack->length];
}

static void *_stack_peek(struct stack_s stack, size_t size) {
  unsigned length = (size - 1) / sizeof(size_t) + 1;
  return &stack.data[stack.length - length];
}

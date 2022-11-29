#pragma once
#ifndef C_FOCUS_H
#define C_FOCUS_H
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
struct c_focus_event_t;
typedef void (*c_focus_event_callback_t)(struct c_focus_event_t);
typedef void (^c_focus_event_block_t)(struct c_focus_event_t);
struct c_focus_state_t {
  bool                     active;
  c_focus_event_callback_t callback;
  c_focus_event_block_t    block;
};
struct c_focus_event_t {
  struct {
    unsigned long timestamp;
  } time;
  struct {
    int x, y;
  } mouse;
  struct {
    pid_t pid;
    char *executable;
  } process;
  struct {
    char  *name, *path, *title;
  } app;
  struct {
    uint32_t id;
    char *uuid;
  } display;
  struct {
    uint32_t id;
  } space;
  struct {
    uint32_t id;
  } window;
};
int __c_focus_callback(c_focus_event_callback_t callback);
int __c_focus_block(c_focus_event_block_t block);

#endif

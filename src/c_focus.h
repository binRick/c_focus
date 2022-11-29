#pragma once
#ifndef C_FOCUS_H
#define C_FOCUS_H
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
struct c_focus_event_t;
typedef void (*c_focus_event_callback_t)(struct c_focus_event_t);
typedef void (^c_focus_event_block_t)(struct c_focus_event_t);
struct c_focus_event_t {
  struct {
    unsigned long timestamp;
  } time;
  struct {
    pid_t pid;
    char  *name, *path, *title, *executable;
  } app;
};
int __c_focus_callback(c_focus_event_callback_t callback);
int __c_focus_block(c_focus_event_block_t block);

#endif

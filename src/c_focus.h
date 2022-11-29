#pragma once
#ifndef C_FOCUS_H
#define C_FOCUS_H
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>
struct c_focus_event_t;
typedef void(*c_focus_event_callback_t)(struct c_focus_event_t);
typedef void(^c_focus_event_callback_b)(struct c_focus_event_t);
struct c_focus_event_t {
  struct {
    unsigned long timestamp;
    pid_t pid;
    char *name, *path, *title, *executable;
  } app;
};
int __c_focus_watch(c_focus_event_callback_t callback);
int __c_focus_watch_b(c_focus_event_callback_b callback);

#endif

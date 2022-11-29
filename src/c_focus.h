#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>

unsigned long __c_focus__timestamp(void);
struct c_focus_event_t;
typedef void(*c_focus_event_callback_t)(struct c_focus_event_t);
struct c_focus_event_t {
  struct {
    unsigned long timestamp;
    pid_t pid;
    char *name, *path, *title, *executable;
  } app;
};
int fw_main(c_focus_event_callback_t callback);


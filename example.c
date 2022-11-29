#include "src/c_focus.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void __focus_changed_callback(struct c_focus_event_t e){
  printf("Focus Changed |PID:%d|Name:%s|Title:%s|Time:%ld|Path:%s|Executable:%s|\n",
         e.app.pid,
         e.app.name,
         e.app.title,
         e.time.timestamp,
         e.app.path,
         e.app.executable
         );
}

int main(int argc, const char *argv[]) {
  return(__c_focus_callback(__focus_changed_callback));
}

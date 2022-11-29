#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include "src/c_focus.h"

void __focus_changed_callback(struct c_focus_event_t e){
  printf("Focus Changed |PID:%d|Name:%s|Title:%s|Time:%ld|Path:%s|Executable:%s|\n",
      e.app.pid,
      e.app.name,
      e.app.title,
      e.app.timestamp,
      e.app.path,
      e.app.executable
      );
}

int main(int argc, const char * argv[]) {
  return(__c_focus_watch(__focus_changed_callback));
}

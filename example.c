#include "src/c_focus.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "fsio.h"
#include "stringfn.h"

void __focus_changed_callback(struct c_focus_event_t e){
  char *json=__c_focus_serialize_event(&e);
  printf("%s\n",json);
  printf("Focus Changed "
      "|Mouse:%dx%d"
      "|Position:%dx%d"
      "|Space ID:%d|Display ID:%d|Window ID:%d|PID:%d|Name:%s|Title:%s|Time:%ld|Path:%s|Executable:%s|\n",
      e.mouse.x,e.mouse.y,
      e.window.x,e.window.y,
         e.space.id,
         e.display.id,
         e.window.id,
         e.process.pid,
         e.app.name,
         e.app.title,
         e.time.timestamp,
         e.app.path,
         e.process.executable
         );
}

int main(int argc, const char *argv[]) {
  return(__c_focus_callback(__focus_changed_callback));
}

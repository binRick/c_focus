#include "fsio.h"
#include "src/c_focus.h"
#include "stringfn.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
static struct example_logger_t {
  char *log_path;
  bool verbose;
} _cfg, *cfg = &_cfg;

void __focus_changed_callback(struct c_focus_event_t e){
  char *json = __c_focus_serialize_event(&e);

  if (cfg->verbose) {
    char *msg;
    asprintf(&msg, "Logging %lu bytes to log file %s\n", strlen(json), cfg->log_path);
    fprintf(stderr, "%s\n", msg);
    free(msg);
  }
  fsio_mkdirs_parent(cfg->log_path, 0700);
  stringfn_mut_trim(json);
  asprintf(&json, "%s\n", json);
  if (json && cfg->log_path)
    if (!fsio_append_text_file(cfg->log_path, json))
      fprintf(stderr, "Failed to append log event\n");
  if (json)
    free(json);
}

int main(int argc, const char *argv[]) {
  if (argc != 2 || !argv[1] || !strlen(argv[1])) {
    fprintf(stderr, "First argument must be a log file path\n");
    exit(EXIT_FAILURE);
  }
  asprintf(&(cfg->log_path), "%s", argv[1]);
  return(__c_focus_callback(__focus_changed_callback));
}

#include "c_focus.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface MDAppController : NSObject<NSApplicationDelegate> {
  NSRunningApplication *currentApp;
}
@property (retain) NSRunningApplication *currentApp;
@end

@implementation MDAppController
@synthesize currentApp;

static c_focus_event_callback_t focus_callback = NULL;
static c_focus_event_block_t    focus_block    = NULL;
static struct c_focus_state_t state = { 0 };
static int __c_focus(void);
static unsigned long __c_focus__timestamp(void);

- (id)init {
  if ((self = [super init]))
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
     selector:@selector(activeAppDidChange:)
     name:NSWorkspaceDidActivateApplicationNotification object:nil];
  return(self);
}
- (void)dealloc {
  [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
  [super dealloc];
}

- (void)activeAppDidChange:(NSNotification *)notification {
  self.currentApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  struct c_focus_event_t e = {
    .time         = {
      .timestamp  = __c_focus__timestamp(),
    },
    .app          = {
      .pid        = currentApp.processIdentifier,
      .name       = (char *)[currentApp.localizedName UTF8String],
      .executable = (char *)[currentApp.executableURL.absoluteString UTF8String],
      .path       = (char *)[currentApp.bundleURL.absoluteString UTF8String],
      .title      = (char *)[currentApp.bundleIdentifier UTF8String],
    },
  };
  if (focus_callback)
    focus_callback(e);
  else if (focus_block)
    focus_block(e);
}
@end

static int __c_focus(void){
  state.active=true;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  [NSApplication sharedApplication];
  MDAppController *appController = [[MDAppController alloc] init];

  [NSApp setDelegate:appController];
  [NSApp run];
  [pool release];
  return(0);
}

int __c_focus_block(c_focus_event_block_t cb){
  focus_block = cb;
  return(__c_focus());
}

int __c_focus_callback(c_focus_event_callback_t cb){
  focus_callback = cb;
  return(__c_focus());
}

static unsigned long __c_focus__timestamp(void){
  struct timeval tv;
  int            ret = gettimeofday(&tv, NULL);

  if (-1 == ret) return(-1);

  return((unsigned long)((int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000));
}

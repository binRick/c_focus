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

static struct c_focus_state_t state;
static unsigned long __c_focus__timestamp(void);
static int __c_focus_event_handler(void);

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
  if (!state.active)
    return;

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

  if (state.callback)
    state.callback(e);
  else if (state.block)
    state.block(e);
}
@end

static int __c_focus_event_handler(void){
  state.active = true;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  [NSApplication sharedApplication];
  MDAppController *appController = [[MDAppController alloc] init];

  [NSApp setDelegate:appController];
  [NSApp run];
  [pool release];
  return(0);
}

static unsigned long __c_focus__timestamp(void){
  struct timeval tv;
  int            ret = gettimeofday(&tv, NULL);

  if (-1 == ret) return(-1);

  return((unsigned long)((int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000));
}

int __c_focus_block(c_focus_event_block_t cb){
  state.block = cb;
  return(__c_focus_event_handler());
}

int __c_focus_callback(c_focus_event_callback_t cb){
  state.callback = cb;
  return(__c_focus_event_handler());
}

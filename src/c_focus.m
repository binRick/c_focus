#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "c_focus.h"

@interface MDAppController : NSObject <NSApplicationDelegate> {
    NSRunningApplication    *currentApp;
}
@property (retain) NSRunningApplication *currentApp;
@end

@implementation MDAppController
@synthesize currentApp;

static c_focus_event_callback_t callback = NULL;
static c_focus_event_callback_b callback_b = NULL;
static int __c_focus(void);
static unsigned long __c_focus__timestamp(void);

- (id)init {
    if ((self = [super init])) {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                      selector:@selector(activeAppDidChange:)
               name:NSWorkspaceDidActivateApplicationNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [super dealloc];
}

- (void)activeAppDidChange:(NSNotification *)notification {
    self.currentApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
      struct c_focus_event_t e = {
        .app = {
          .pid=currentApp.processIdentifier,
          .name=(char*)[currentApp.localizedName UTF8String],
          .executable=(char*)[currentApp.executableURL.absoluteString UTF8String],
          .path=(char*)[currentApp.bundleURL.absoluteString UTF8String],
          .title=(char*)[currentApp.bundleIdentifier UTF8String],
          .timestamp=__c_focus__timestamp(),
        },
     };
    if(callback)
      callback(e);
    else if(callback_b)
      callback_b(e);
}
@end

static int __c_focus(void){
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];
  MDAppController *appController = [[MDAppController alloc] init];
  [NSApp setDelegate:appController];
  [NSApp run];
  [pool release];
  return 0;
}
int __c_focus_watch_b(c_focus_event_callback_b cb){
  callback_b=cb;
  return __c_focus();
}

int __c_focus_watch(c_focus_event_callback_t cb){
  callback=cb;
  return __c_focus();
}

static unsigned long __c_focus__timestamp(void){
  struct timeval tv;
  int            ret = gettimeofday(&tv, NULL);
  if (-1 == ret) return(-1);
  return((unsigned long)((int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000));
}


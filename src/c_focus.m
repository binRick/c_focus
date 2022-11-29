#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "c_focus.h"

unsigned long __c_focus__timestamp(void){
  struct timeval tv;
  int            ret = gettimeofday(&tv, NULL);
  if (-1 == ret) return(-1);
  return((unsigned long)((int64_t)tv.tv_sec * 1000 + (int64_t)tv.tv_usec / 1000));
}

@interface MDAppController : NSObject <NSApplicationDelegate> {
    NSRunningApplication    *currentApp;
}
@property (retain) NSRunningApplication *currentApp;
@end

@implementation MDAppController
@synthesize currentApp;

static c_focus_event_callback_t callback = NULL;

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
    const char *cString = [currentApp.localizedName UTF8String];
    if(callback)
      callback((struct c_focus_event_t){
        .app = {
          .pid=currentApp.processIdentifier,
          .name=(char*)[currentApp.localizedName UTF8String],
          .executable=(char*)[currentApp.executableURL.absoluteString UTF8String],
          .path=(char*)[currentApp.bundleURL.absoluteString UTF8String],
          .title=(char*)[currentApp.bundleIdentifier UTF8String],
          .timestamp=__c_focus__timestamp(),
        },
          });
}
@end

int fw_main(c_focus_event_callback_t cb){
  callback=cb;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];
  MDAppController *appController = [[MDAppController alloc] init];
  [NSApp setDelegate:appController];
  [NSApp run];
  [pool release];
  return 0;
}

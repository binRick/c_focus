#include "c_focus.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
extern AXError _AXUIElementGetWindow(AXUIElementRef, uint32_t *);
extern CFStringRef SLSCopyManagedDisplayForWindow(int cid, uint32_t wid);
extern int CGSMainConnectionID(void);
extern uint64_t SLSManagedDisplayGetCurrentSpace(int, CFStringRef);

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

- (void) quit {
  [NSApp terminate:self];
}

- (void) setMenuItemIcon:(NSArray*)imageAndMenuId {
  NSImage* image = [imageAndMenuId objectAtIndex:0];
  NSNumber* menuId = [imageAndMenuId objectAtIndex:1];
  NSMenuItem* menuItem;
  if (menuItem == NULL) {
    return;
  }
  menuItem.image = image;
}

- (void)activeAppDidChange:(NSNotification *)notification {
  if (!state.active)
    return;

  self.currentApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
  CFTypeRef window_ref = NULL;
  uint32_t window_id = 0, display_id =0, space_id=0;
  AXUIElementRef app;
  app = AXUIElementCreateApplication(currentApp.processIdentifier);

  if(!app){
      fprintf(stderr,"Failed to get Focused app\n");
  }else{
    AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute, &window_ref);
    if(!window_ref){
      fprintf(stderr,"Failed to Copy Focused app for pid %d\n",currentApp.processIdentifier);
    }else{
      _AXUIElementGetWindow(window_ref, &window_id);
      CFRelease(window_ref);
    }
    CFRelease(app);
  }
  if(window_id>0){
    CFStringRef _uuid = SLSCopyManagedDisplayForWindow(CGSMainConnectionID(), window_id);
    CFUUIDRef   uuid  = CFUUIDCreateFromString(NULL, _uuid);
    display_id = CGDisplayGetDisplayIDFromUUID(uuid);
    if(display_id>0){
      space_id = SLSManagedDisplayGetCurrentSpace(CGSMainConnectionID(), _uuid);
    }
    CFRelease(_uuid);
    CFRelease(uuid);  
  }

  CGEventRef Event = CGEventCreate(nil);
  CGPoint    mouse_loc     = CGEventGetLocation(Event);
  CFRelease(Event);

  struct c_focus_event_t e = {
    .time         = {
      .timestamp  = __c_focus__timestamp(),
    },
    .mouse={
      .x=(int)(mouse_loc.x),
      .y=(int)(mouse_loc.y),
    },
    .space = {
      .id=space_id,
    },
    .display = {
      .id=display_id,
    },
    .window = {
      .id=window_id,
    },
    .process={
      .pid        = (pid_t)currentApp.processIdentifier,
      .executable = (char *)[currentApp.executableURL.absoluteString UTF8String],
    },
    .app          = {
      .name       = (char *)[currentApp.localizedName UTF8String],
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

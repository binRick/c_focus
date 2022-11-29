#include "c_focus.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include "fsio.h"
#include "stringfn.h"
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

static const char *path_prefix="file://";
static struct c_focus_state_t state;
static unsigned long __c_focus__timestamp(void);
static int __c_focus_event_handler(void);
static void __c_focus_normalize_event(struct c_focus_event_t *);
static void AXWindowGetValue(AXUIElementRef window,
                      CFStringRef    attrName,
                      void           *valuePtr);
static void __c_focus_normalize_event(struct c_focus_event_t *ev){
  if(ev->process.executable)
    if(stringfn_starts_with(ev->process.executable,path_prefix))
      ev->process.executable=stringfn_substring(ev->process.executable,strlen(path_prefix),strlen(ev->app.path)-strlen(ev->app.path));
  if(ev->app.path)
    if(stringfn_starts_with(ev->app.path,path_prefix))
      ev->app.path=stringfn_substring(ev->app.path,strlen(path_prefix),strlen(ev->app.path)-strlen(ev->app.path));
  if(stringfn_ends_with(ev->app.path,"/"))
    ev->app.path=stringfn_substring(ev->app.path,0,strlen(ev->app.path)-1);
}

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

  CGPoint window_position;
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
      AXWindowGetValue(window_ref, kAXPositionAttribute, &window_position);
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
      .x=(int)(window_position.x),
      .y=(int)(window_position.y),
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
  __c_focus_normalize_event(&e);

  if (state.callback)
    state.callback(e);
  else if (state.block)
    state.block(e);
}
static void AXWindowGetValue(AXUIElementRef window,
                      CFStringRef    attrName,
                      void           *valuePtr) {
  AXValueRef attrValue;

  AXUIElementCopyAttributeValue(window, attrName, (CFTypeRef *)&attrValue);
  AXValueGetValue(attrValue, AXValueGetType(attrValue), valuePtr);
  CFRelease(attrValue);
}
@end

char *__c_focus_serialize_event(struct c_focus_event_t *ev){
  char *s,*w,*a,*d,*t,*m,*e;
  asprintf(&e,
      "{"
      "\"executable:\":\"%s\""
      ",\"pid:\":%d"
      "}"
      "%s",
      ev->process.executable,
      ev->process.pid,
      ""
      );
  asprintf(&m,
      "{"
      "\"x:\":%d"
      ",\"y:\":%d"
      "}"
      "%s",
      ev->mouse.x,
      ev->mouse.y,
      ""
      );
  asprintf(&t,
      "{"
      "\"timestamp:\":\"%ld\""
      "}"
      "%s",
      ev->time.timestamp,
      ""
      );
  asprintf(&a,
      "{"
      "\"name:\":\"%s\""
      ",\"path:\":\"%s\""
      ",\"title:\":\"%s\""
      "}"
      "%s",
      ev->app.name,
      ev->app.path,
      ev->app.title,
      ""
      );
  asprintf(&s,
      "{"
      "\"id:\":%d"
      "}"
      "%s",
      ev->space.id,
      ""
      );
  asprintf(&d,
      "{"
      "\"id:\":%d"
      "}"
      "%s",
      ev->display.id,
      ""
      );
  asprintf(&w,
      "{"
      "\"id:\":%d"
      "\"width:\":%d"
      "\"height:\":%d"
      "\"x:\":%d"
      "\"y:\":%d"
      "}"
      "%s",
      ev->window.id,
      ev->window.width,
      ev->window.height,
      ev->window.x,
      ev->window.y,
      ""
      );
  asprintf(&s,
      "{"
      "\"window:\":%s"
      ",\"display:\":%s"
      ",\"space:\":%s"
      ",\"mouse:\":%s"
      ",\"app:\":%s"
      ",\"executable:\":%s"
      "}"
      "%s",
      w,
      d,
      s,
      m,
      a,
      e,
      ""
      );
  return(s);
}

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

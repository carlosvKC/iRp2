
#import "CrashController.h"

#include <signal.h>
#include <execinfo.h>

static CrashController *sharedInstance = nil;

#pragma mark C Functions 

void sighandler(int signal);
void uncaughtExceptionHandler(NSException *exception);

void sighandler(int signal)
{
    const char* names[NSIG];
    names[SIGABRT] = "SIGABRT";
    names[SIGBUS] = "SIGBUS";
    names[SIGFPE] = "SIGFPE";
    names[SIGILL] = "SIGILL";
    names[SIGPIPE] = "SIGPIPE";
    names[SIGSEGV] = "SIGSEGV";
    
    CrashController *crash = [CrashController sharedInstance];
    NSArray *arr = [crash callstackAsArray];
    NSString *title = [NSString stringWithFormat:@"Crash: %@", [arr objectAtIndex:6]];  // The 6th frame is where the crash happens
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                              title, @"Title",
                              [NSNumber numberWithInt:signal], @"Signal",
                              [NSString stringWithUTF8String:names[signal]], @"Signal Name",
                              nil];
    [crash performSelectorOnMainThread:@selector(handleSignal:) withObject:userInfo waitUntilDone:YES];
}

void uncaughtExceptionHandler(NSException *exception)
{
    CrashController *crash = [CrashController sharedInstance];
    NSArray *arr = [crash callstackAsArray];
    NSString *title = [NSString stringWithFormat:@"Exception: %@", [arr objectAtIndex:8]];  // The 8th frame is where the exception is thrown
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                              title, @"Title",
                              exception, @"Exception",
                              nil];
    [crash performSelectorOnMainThread:@selector(handleNSException:) withObject:userInfo waitUntilDone:YES];
}

@implementation CrashController

#pragma mark Singleton methods

+(CrashController *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[CrashController alloc] init];
    }
    
    return sharedInstance;
}
- (void)handleSignal:(NSDictionary*)userInfo
{  
    NSLog(@"%@", userInfo);
}

- (void)handleNSException:(NSDictionary*)userInfo
{
    NSLog(@"%@", userInfo);
}

#pragma mark Lifetime methods

- (id)init
{
    if ((self = [super init]))
    {
        signal(SIGABRT, sighandler);
        signal(SIGBUS, sighandler);
        signal(SIGFPE, sighandler);
        signal(SIGILL, sighandler);
        signal(SIGPIPE, sighandler);    
        signal(SIGSEGV, sighandler);
        
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    }
    
    return self;
}

- (void)dealloc
{
    signal(SIGABRT, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    
    NSSetUncaughtExceptionHandler(NULL);
    
}

#pragma mark methods

- (NSArray*)callstackAsArray
{
    void* callstack[128];
    const int numFrames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, numFrames);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames];
    for (int i = 0; i < numFrames; ++i) 
    {
        [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
    }
    
    free(symbols);
    
    return arr;
}



@end


 // 11/30/2011

#import "RealPropertyApp.h"



 int main(int argc, char *argv[])
{
    @autoreleasepool 
    {
#if TARGET_IPHONE_SIMULATOR
        @try 
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([RealPropertyApp class]));
        }
        @catch (NSException *exception) 
        {
            NSLog(@"%@", [exception reason]);
            NSLog(@"%@", [exception userInfo]);
            NSLog(@"%@", exception);
        }
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([RealPropertyApp class]));        
#endif
    }
}

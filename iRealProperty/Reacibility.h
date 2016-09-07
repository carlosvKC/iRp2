
#import <Foundation/Foundation.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

enum kNetworkStatus
{
    kNetworkNotReacheable,
    kNetworkWiFi,
    kNetworkWireless,
    kNetworkWan
};

@interface Reacibility : NSObject

@end

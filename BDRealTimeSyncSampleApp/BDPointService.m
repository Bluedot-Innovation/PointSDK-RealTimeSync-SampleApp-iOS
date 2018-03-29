//
//  BDPointService.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 3/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDPointService.h"
@import BDPointSDK;
#import "BDFirebaseConstants.h"

static NSString *kBDPointAPIKey         = @"Your-Bluedot-App-API-Key";
static NSString *kBDPointPackageName    = @"Your-Bluedot-App-Package-Name";
static NSString *kBDPointUsername       = @"Your-Bluedot-App-Username";

static NSString *topicPrefix = @"/topics/";

@implementation BDPointService

+ (instancetype)instance
{
    static BDPointService  *instance = nil;
    static dispatch_once_t dispatchOncePredicate  = 0;
    
    dispatch_block_t singletonInit = ^
    {
        dispatch_block_t mainInit = ^
        {
            instance = [ [ BDPointService alloc ] init ];
        };
        
        if( NSThread.currentThread.isMainThread )
        {
            mainInit();
        }
        else
        {
            dispatch_sync( dispatch_get_main_queue(), mainInit );
        }
    };
    
    dispatch_once( &dispatchOncePredicate, singletonInit );
    
    return( instance );
}

- (void)start
{
    BDLocationManager.instance.pointDelegate = self;
    [BDLocationManager.instance authenticateWithApiKey:kBDPointAPIKey
                                           packageName:kBDPointPackageName
                                              username:kBDPointUsername];
}

- (NSString *)topicToSubscribe
{
    return [topicPrefix stringByAppendingString: kBDPointAPIKey];
}

#pragma mark BDPointDelegate

- (void)authenticationWasSuccessful
{
    NSString *message = [NSString stringWithFormat: @"Bluedot Point SDK authentication was successful\n"];
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                                        object: nil
                                                      userInfo: @{@"log": message}];
}

- (void)authenticationWasDeniedWithReason: (NSString *)reason
{
    NSString *message = [NSString stringWithFormat: @"Bluedot Point SDK authentication was denied: %@\n", reason];
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                                        object: nil
                                                      userInfo: @{@"log": message}];
}

- (void)authenticationFailedWithError: (NSError *)error
{
    NSString *message = [NSString stringWithFormat: @"Bluedot Point SDK authentication was failed: %@\n", error.localizedDescription];
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                                        object: nil
                                                      userInfo: @{@"log": message}];
}

- (void)didUpdateZoneInfo:(NSSet *)zoneInfos
{
    _zoneInfos = zoneInfos;
    NSString *message = [NSString stringWithFormat: @"Rules updated at: %@\nZones count:%lu\n", now(), zoneInfos.count];
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                                        object: nil
                                                      userInfo: @{@"log": message}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDZoneInfoUpdateNotification
                                                        object: nil
                                                      userInfo: nil];
}

- (void)willAuthenticateWithUsername: (NSString *)username
                              apiKey: (NSString *)apiKey
                         packageName: (NSString *)packageName
{
}

- (void)didEndSession
{
}

- (void)didEndSessionWithError: (NSError *)error
{
}


@end

//
//  AppDelegate.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import UserNotifications;
@import BDPointSDK;

// Implement FIRMessagingDelegate to receive data message via FCM
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate, BDPGeoTriggeringEventDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // [START configure_firebase]
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    // [END configure_firebase]
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound |
        UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:authOptions
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
         if (granted == YES)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication] registerForRemoteNotifications];
             });
         }
     }];
    
    BDLocationManager.instance.geoTriggeringEventDelegate = self;
    
    
    return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //    [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeSandbox];
    [FIRMessaging messaging].APNSToken = deviceToken;
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: Token ID: %@", [FIRMessaging messaging].APNSToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler:");
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@", userInfo);
    
    [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
    
}

// Receive displayed notifications for iOS 10 devices.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"Subcribing to Topic...");
    NSString *topic = [NSString stringWithFormat:@"%@", ProjectId];
    [[FIRMessaging messaging] subscribeToTopic: topic];
}

#pragma mark BDPGeoTriggeringDelegate

- (void)didEnterZone:(BDZoneEntryEvent *)enterEvent
{
    NSLog(@"Entered zone");
}

- (void)onZoneInfoUpdate:(NSSet<BDZoneInfo *> *)zoneInfos
{
    _zoneInfos = zoneInfos;
    NSString *message = [NSString stringWithFormat: @"Zone updated at: %@\nZones count:%lu\n", now(), zoneInfos.count];
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                                        object: nil
                                                      userInfo: @{@"log": message}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kBDZoneInfoUpdateNotification
                                                        object: nil
                                                      userInfo: nil];
}

@end

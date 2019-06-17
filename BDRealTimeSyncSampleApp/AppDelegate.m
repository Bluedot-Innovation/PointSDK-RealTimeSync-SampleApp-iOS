//
//  AppDelegate.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "BDFirebaseConstants.h"

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;
@import UserNotifications;
@import BDPointSDK;

// Implement FIRMessagingDelegate to receive data message via FCM
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate, BDPSessionDelegate, BDPLocationDelegate>

@end

@implementation AppDelegate

static NSString *kBDPointAPIKey = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [START configure_firebase]
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    // [END configure_firebase]
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert
                                        | UNAuthorizationOptionSound
                                        | UNAuthorizationOptionBadge;
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
    
    BDLocationManager.instance.locationDelegate = self;
    BDLocationManager.instance.sessionDelegate = self;
    
    [BDLocationManager.instance authenticateWithApiKey:kBDPointAPIKey requestAuthorization:authorizedAlways];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
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
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage{
    // Print full message
    NSDictionary *userInfo = [remoteMessage appData];
    NSLog(@"%@", userInfo);
    
    [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"Subcribing to Topic...");
    NSString *topic = [NSString stringWithFormat:@"/topics/%@", kBDPointAPIKey];
    [[FIRMessaging messaging] subscribeToTopic: topic];
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

- (void)willAuthenticateWithApiKey: (NSString *)apiKey
{
}

- (void)didEndSession
{
}

- (void)didEndSessionWithError: (NSError *)error
{
}

@end

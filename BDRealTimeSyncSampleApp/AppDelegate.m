//
//  AppDelegate.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#import "BDPointService.h"
#import "BDFirebaseConstants.h"
@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register for remote notifications
    // iOS 8 or later
    // [START register_for_notifications]
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
         }
         ];
        
        // For iOS 10 display notification (sent via APNS)
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
        // For iOS 10 data message (sent via FCM)
        [[FIRMessaging messaging] setRemoteMessageDelegate:self];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    // [END register_for_notifications]
    
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(tokenRefreshNotification:)
                                                 name: kFIRInstanceIDTokenRefreshNotification
                                               object: nil];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"Subscribed to news topic");
    
    NSString *topic = [BDPointService.instance topicToSubscribe];
    
    [[FIRMessaging messaging] subscribeToTopic: topic];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification:");
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@", userInfo);
    
    if ( [ userInfo[@"identifier"] isEqualToString: @"io.bluedot" ] )
    {
        NSString *log = [NSString stringWithFormat:@"Push received at: %@\n", now()];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDConsoleLogNotification object:nil userInfo:@{@"log": log}];
        [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler:");
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@", userInfo);
    
    if ( [ userInfo[@"identifier"] isEqualToString: @"io.bluedot" ] )
    {
        NSString *log = [NSString stringWithFormat:@"Push received at: %@\n", now()];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDConsoleLogNotification object:nil userInfo:@{@"log": log}];
        [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
    }
}

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    if ( [ userInfo[@"identifier"] isEqualToString: @"io.bluedot" ] )
    {
        NSString *log = [NSString stringWithFormat:@"Push received at: %@\n", now()];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDConsoleLogNotification object:nil userInfo:@{@"log": log}];
        [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
    }
}

// Receive data message on iOS 10 devices.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
    NSDictionary *userInfo = [remoteMessage appData];
    NSLog(@"%@", userInfo);
    
    if ( [ userInfo[@"identifier"] isEqualToString: @"io.bluedot" ] )
    {
        NSString *log = [NSString stringWithFormat:@"Push received at: %@\n", now()];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDConsoleLogNotification object:nil userInfo:@{@"log": log}];
        [BDLocationManager.instance notifyPushUpdateWithData:userInfo];
    }
}
#endif


// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification
{
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm
{
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error)
     {
         if (error != nil) {
             NSLog(@"Unable to connect to FCM. %@", error);
         } else {
             NSLog(@"Connected to FCM.");
         }
     }];
}
// [END connect_to_fcm]

@end

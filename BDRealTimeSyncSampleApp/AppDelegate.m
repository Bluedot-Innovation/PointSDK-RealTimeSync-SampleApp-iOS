//
//  AppDelegate.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"


#import "BDPointService.h"
#import "BDFirebaseConstants.h"
@import Firebase;
@import FirebaseInstanceID;
#import <FirebaseMessaging/FirebaseMessaging.h>
@import UserNotifications;

// Implement FIRMessagingDelegate to receive data message via FCM
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
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
         }
         ];
    
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    // [START configure_firebase]
    [FIRMessaging messaging].delegate = self;
    [FIRApp configure];
    [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    // [END configure_firebase]
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [FIRMessaging messaging].APNSToken = deviceToken;
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: Token ID: %@", [FIRMessaging messaging].APNSToken);
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

// Receive displayed notifications for iOS 10 devices.
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

- (void) messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"Subcribing to Topic...");
    NSString *topic = [BDPointService.instance topicToSubscribe];
    [[FIRMessaging messaging] subscribeToTopic: topic];
}

@end

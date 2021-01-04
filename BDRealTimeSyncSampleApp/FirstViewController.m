//
//  FirstViewController.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "FirstViewController.h"
#import "Constants.h"
@import BDPointSDK;

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITextView *consoleLogTextView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(didReceiveConsoleLogNotification:) name:kBDConsoleLogNotification object:nil ];
    
    [BDLocationManager.instance initializeWithProjectId: ProjectId completion:^(NSError * _Nullable error) {
        if(error != nil){
            NSString *message = [NSString stringWithFormat: @"Bluedot Point SDK initialization failed: %@\n", error.localizedDescription];
            [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                              object: nil
                            userInfo: @{@"log": message}];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                          object: nil
                        userInfo: @{@"log": @"Bluedot SDK Initialised\n"}];
        
        [BDLocationManager.instance startGeoTriggeringWithCompletion:^(NSError * _Nullable error) {
            if(error != nil){
                NSString *message = [NSString stringWithFormat: @"Start GeoTriggering failed: %@\n", error.localizedDescription];
                [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                                  object: nil
                                userInfo: @{@"log": message}];
                return;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName: kBDConsoleLogNotification
                              object: nil
                            userInfo: @{@"log": @"Geotriggering Running\n"}];
        }];
    }];
    
}

- (void)dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver:self name:kBDConsoleLogNotification object:nil ];
}

- (void)didReceiveConsoleLogNotification:(NSNotification *) notification
{
    NSString *log = notification.userInfo[@"log"];
    _consoleLogTextView.text = [_consoleLogTextView.text stringByAppendingString:log];
}

@end

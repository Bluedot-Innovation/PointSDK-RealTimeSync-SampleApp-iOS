//
//  OnboardingViewController.m
//  BDRealTimeSyncSampleApp
//
//  Created by Duncan Lau on 17/12/20.
//  Copyright © 2020 Bluedot Innovation. All rights reserved.
//

#import "OnboardingViewController.h"
@import BDPointSDK;

@interface OnboardingViewController ()

@end

@implementation OnboardingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _nextButton.layer.cornerRadius = 9.0;
    _nextButton.layer.borderColor  = [UIColor systemBlueColor].CGColor;
    _nextButton.layer.borderWidth  = 1.0;
    
}

- (IBAction)allowLocationAccessTouchUpInside:(id)sender {
    [BDLocationManager.instance requestAlwaysAuthorization];
}


@end

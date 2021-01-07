//
//  OnboardingViewController.h
//  BDRealTimeSyncSampleApp
//
//  Created by Duncan Lau on 17/12/20.
//  Copyright © 2020 Bluedot Innovation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)allowLocationAccessTouchUpInside:(id)sender;

@end

//
//  FirstViewController.m
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 5/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "FirstViewController.h"
#import "BDFirebaseConstants.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITextView *consoleLogTextView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(didReceiveConsoleLogNotification:) name:kBDConsoleLogNotification object:nil ];
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

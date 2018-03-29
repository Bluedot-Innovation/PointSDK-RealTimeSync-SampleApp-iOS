//
//  BDPointService.h
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 3/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

@import BDPointSDK;

@interface BDPointService : NSObject<BDPointDelegate>

@property (nonatomic) NSSet *zoneInfos;

+ (instancetype)instance;

- (void)start;

- (NSString *)topicToSubscribe;

@end

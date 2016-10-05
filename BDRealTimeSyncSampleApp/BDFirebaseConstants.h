//
//  BDFirebaseUtilities.h
//  BDRealTimeSyncSampleApp
//
//  Created by Jason Xie on 3/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

static NSString *kBDConsoleLogNotification = @"kBDConsoleLogNotificationKey";

static NSString *kBDZoneInfoUpdateNotification = @"kBDZoneInfoUpdateNotificationKey";

static NSString* now()
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

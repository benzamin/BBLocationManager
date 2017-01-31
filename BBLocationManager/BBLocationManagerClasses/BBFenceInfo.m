//
//  BBFenceInfo.m
//  SDK_iOS_DATA
//
//  Created by Benzamin on 4/23/15.
//  Copyright (c) 2015 Benzamin. All rights reserved.
//

#import "BBFenceInfo.h"

@implementation BBFenceInfo

- (NSDictionary *)dictionary
{
    return @{ BB_FENCE_EVENT_TYPE_KEY         : self.eventType ? _eventType : [NSNull null],
              BB_FENCE_EVENT_TIMESTAMP_KEY    : self.eventTimeStamp ? _eventTimeStamp : [NSNull null],
              BB_FENCE_IDENTIFIER_KEY         : self.fenceIDentifier ? _fenceIDentifier : [NSNull null],
              BB_FENCE_COORDINATE_KEY         : self.fenceCoordinate ? _fenceCoordinate : [NSNull null] };

}
@end

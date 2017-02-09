//
//  BBFenceInfo.h
//
//  Created by Benzamin on 4/23/15.
//  Copyright (c) 2015 Benzamin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BB_FENCE_EVENT_TYPE_KEY @"BBeventType"
#define BB_FENCE_EVENT_TIMESTAMP_KEY @"BBeventTimeStamp"
#define BB_FENCE_IDENTIFIER_KEY @"BBfenceIDentifier"
#define BB_FENCE_COORDINATE_KEY @"BBfenceCoordinate"

#define BB_GET_FENCE_EVENT_STRING(fenceEventTypeEnum) [@[ @"BBFenceEventAdded", @"BBFenceEventRemoved",@"BBFenceEventFailed", @"BBFenceEventRepeated", @"BBFenceEventEnterFence",@"BBFenceEventExitFence", @"BBFenceEventNone"] objectAtIndex:(fenceEventTypeEnum)]

typedef enum : NSUInteger {
    BBFenceEventTypeAdded,
    BBFenceEventTypeRemoved,
    BBFenceEventTypeFailed,
    BBFenceEventTypeRepeated,
    BBFenceEventTypeEnterFence,
    BBFenceEventTypeExitFence,
    BBFenceEventTypeNone
} BBFenceEventType;

@interface BBFenceInfo : NSObject


@property(nonatomic, assign) NSString *eventType;
@property(nonatomic, strong) NSString *eventTimeStamp;
@property(nonatomic, strong) NSString *fenceIDentifier;
@property(nonatomic, strong) NSDictionary *fenceCoordinate;//uses BB_LATITUDE,  BB_LONGITUDE, BB_RADIOUS to wrap data

- (NSDictionary*)dictionary;



@end

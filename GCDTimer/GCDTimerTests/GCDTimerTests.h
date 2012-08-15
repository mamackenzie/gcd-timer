//
//  GCDTimerTests.h
//  GCDTimerTests
//
//  Created by Michael Mackenzie on 2012-08-06.
//  Copyright (c) 2012 Michael Mackenzie. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GCDTimer.h"

@interface GCDTimerTests : SenTestCase
{
    GCDTimer *_timer;
}

- (void)testConstruction;
- (void)testTimerFires;
- (void)testTimerDoesntFireTooSoon;
- (void)testTimerRepeats;
- (void)testTimerInvalidates;
- (void)testTimerFiresOnDifferentQueue;
- (void)testTimerDoesntFireTooSoonOnDifferentQueue;
- (void)testTimerRepeatsOnDifferentQueue;
- (void)testTimerInvalidatesOnDifferentQueue;
- (void)testTimerWithHighLeeway;

@end

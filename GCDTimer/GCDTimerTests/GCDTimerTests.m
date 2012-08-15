//
//  GCDTimerTests.m
//  GCDTimerTests
//
//  Created by Michael Mackenzie on 2012-08-06.
//  Copyright (c) 2012 Michael Mackenzie. All rights reserved.
//

#import "GCDTimerTests.h"

/**
 * @todo Use dispatch semaphores for testing!
 * @todo Make a test utility function RunLoopWait(NSTimeInterval interval);
 */

@implementation GCDTimerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testOneShotTimer
{
    __block BOOL timerHasFired = NO;
    
    _timer = [GCDTimer timerOnCurrentQueue];
    
    [_timer scheduleBlock:^{
        timerHasFired = YES;
    } afterInterval:0.01];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    
    STAssertFalse(timerHasFired, @"10 millisecond timer fired before 5 milliseconds.");
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    STAssertTrue(timerHasFired, @"10 millisecond timer didn't fire after 1.5 seconds.");
}


- (void)testRepeatedTimer
{
    __block NSUInteger numTimerEvents = 0;
    
    _timer = [GCDTimer timerOnCurrentQueue];
    
    [_timer scheduleBlock:^{ numTimerEvents++; }
            afterInterval:0.01
                   repeat:YES];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.055]];
    
    STAssertTrue(numTimerEvents == 5,
                 @"After 55 milliseconds, a 10 millisecond timer fired %d times.",
                 numTimerEvents);
}

- (void)testConstruction
{
    
}


- (void)testTimerFires
{
    
}


- (void)testTimerDoesntFireTooSoon
{
    
}


- (void)testTimerRepeats
{
    
}


- (void)testTimerInvalidates
{
    
}

@end

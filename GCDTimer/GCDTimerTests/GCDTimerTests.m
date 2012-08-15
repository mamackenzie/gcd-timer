//
//  GCDTimerTests.m
//  GCDTimerTests
//
//  Created by Michael Mackenzie on 2012-08-06.
//  Copyright (c) 2012 Michael Mackenzie. All rights reserved.
//

#import "GCDTimerTests.h"


@implementation GCDTimerTests

- (void)setUp
{
    [super setUp];
}


- (void)tearDown
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    
    [super tearDown];
}


- (void)testConstruction
{
    _timer = [[GCDTimer timerOnCurrentQueue] retain];
    STAssertNotNil(_timer, @"Timer constructor returned nil.");
}


- (void)testTimerFires
{
    __block BOOL timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnCurrentQueue] retain];
    
    [_timer scheduleBlock:^{
        timerHasFired = YES;
    } afterInterval:0.005];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    STAssertTrue(timerHasFired, @"5 millisecond timer didn't fire after 10 milliseconds.");
}


- (void)testTimerDoesntFireTooSoon
{
    __block BOOL timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnCurrentQueue] retain];
    
    [_timer scheduleBlock:^{
        timerHasFired = YES;
    } afterInterval:0.01];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    
    STAssertFalse(timerHasFired, @"10 millisecond timer fired after 5 milliseconds.");
}


- (void)testTimerRepeats
{
    __block NSUInteger numTimerEvents = 0;
    
    _timer = [[GCDTimer timerOnCurrentQueue] retain];
    
    [_timer scheduleBlock:^{ numTimerEvents++; }
            afterInterval:0.01
                   repeat:YES];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.055]];
    
    STAssertTrue(numTimerEvents == 5,
                 @"After 55 milliseconds, a 10 millisecond timer fired %d times.",
                 numTimerEvents);
}


- (void)testTimerInvalidates
{
    __block NSUInteger timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnCurrentQueue] retain];
    
    [_timer scheduleBlock:^{ timerHasFired = YES; } afterInterval:0.01];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    
    [_timer invalidate];
    
    STAssertFalse(timerHasFired, @"10 millisecond timer fired after 5 milliseconds.");
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    STAssertFalse(timerHasFired, @"Timer fired after being invalidated!");
}


- (void)testTimerFiresOnDifferentQueue
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("GCDTimerTestQueue",
                                                           DISPATCH_QUEUE_CONCURRENT);
    
    __block BOOL timerHasFired = NO;
    _timer = [[GCDTimer timerOnQueue:dispatchQueue] retain];
    
    dispatch_release(dispatchQueue);
    
    [_timer scheduleBlock:^{ timerHasFired = YES; } afterInterval:0.005];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    STAssertTrue(timerHasFired, @"5 millisecond timer didn't fire after 10 milliseconds.");
}


- (void)testTimerDoesntFireTooSoonOnDifferentQueue
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("GCDTimerTestQueue",
                                                           DISPATCH_QUEUE_CONCURRENT);
    
    __block BOOL timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnQueue:dispatchQueue] retain];
    
    dispatch_release(dispatchQueue);
    
    [_timer scheduleBlock:^{
        timerHasFired = YES;
    } afterInterval:0.01];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    
    STAssertFalse(timerHasFired, @"10 millisecond timer fired after 5 milliseconds.");
}


- (void)testTimerRepeatsOnDifferentQueue
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("GCDTimerTestQueue",
                                                           DISPATCH_QUEUE_CONCURRENT);
    
    __block NSUInteger numTimerEvents = 0;
    
    _timer = [[GCDTimer timerOnQueue:dispatchQueue] retain];
    
    dispatch_release(dispatchQueue);
    
    [_timer scheduleBlock:^{ numTimerEvents++; }
            afterInterval:0.01
                   repeat:YES];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.055]];
    
    STAssertTrue(numTimerEvents == 5,
                 @"After 55 milliseconds, a 10 millisecond timer fired %d times.",
                 numTimerEvents);
}


- (void)testTimerInvalidatesOnDifferentQueue
{
    dispatch_queue_t dispatchQueue = dispatch_queue_create("GCDTimerTestQueue",
                                                           DISPATCH_QUEUE_CONCURRENT);
    
    __block NSUInteger timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnQueue:dispatchQueue] retain];
    
    dispatch_release(dispatchQueue);
    
    [_timer scheduleBlock:^{ timerHasFired = YES; } afterInterval:0.01];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    
    [_timer invalidate];
    
    STAssertFalse(timerHasFired, @"10 millisecond timer fired after 5 milliseconds.");
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    
    STAssertFalse(timerHasFired, @"Timer fired after being invalidated!");
}


- (void)testTimerWithHighLeeway
{
    __block BOOL timerHasFired = NO;
    
    _timer = [[GCDTimer timerOnCurrentQueueWithLeeway:(1 * NSEC_PER_SEC)
                                                 name:@"TestTimer"] retain];
    
    [_timer scheduleBlock:^{ timerHasFired = YES; } afterInterval:1.0];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
    
    STAssertTrue(timerHasFired, @"1 second timer didn't fire after 2 seconds.");
}

@end

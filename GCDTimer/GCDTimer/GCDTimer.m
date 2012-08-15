//
//  GCDTimer.m
//  GCDTimer
//
//  Copyright (c) 2012, Michael Mackenzie <mike.a.mackenzie@gmail.com>
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose with
//  or without fee is hereby granted, provided that the above copyright notice and this
//  permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
//  TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN
//  NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
//  DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
//  IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
//  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#import "GCDTimer.h"

@implementation GCDTimer

@synthesize isValid = _isValid, name = _name;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue leeway:(uint64_t)leeway name:(NSString *)name
{
    if (self = [super init]) {
        _name = [name copy];
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_retain(_timer);
        
        _leeway = leeway;
        
        _isValid = NO;
    }
    
    return self;
}


- (void)dealloc
{
    [self invalidate];
    [_name release];
    dispatch_release(_timer);
    
    [super dealloc];
}


+ (id)timerOnQueue:(dispatch_queue_t)queue withLeeway:(uint64_t)leeway name:(NSString *)name
{
    return [[[GCDTimer alloc] initWithDispatchQueue:queue leeway:leeway name:name] autorelease];
}


+ (id)timerOnQueue:(dispatch_queue_t)queue withName:(NSString *)name
{
    return [GCDTimer timerOnQueue:queue withLeeway:TIMER_LEEWAY_MEDIUM name:name];
}


+ (id)timerOnQueue:(dispatch_queue_t)queue
{
    return [GCDTimer timerOnQueue:queue withName:nil];
}


+ (id)timerOnCurrentQueueWithLeeway:(uint64_t)leeway name:(NSString *)name
{
    return [GCDTimer timerOnQueue:dispatch_get_current_queue() withLeeway:leeway name:name];
}


+ (id)timerOnCurrentQueueWithName:(NSString *)name
{
    return [GCDTimer timerOnCurrentQueueWithLeeway:TIMER_LEEWAY_MEDIUM name:name];
}


+ (id)timerOnCurrentQueue
{
    return [GCDTimer timerOnCurrentQueueWithName:nil];
}


+ (id)timerOnMainQueueWithLeeway:(uint64_t)leeway name:(NSString *)name
{
    return [GCDTimer timerOnQueue:dispatch_get_main_queue() withLeeway:leeway name:name];
}


+ (id)timerOnMainQueueWithName:(NSString *)name
{
    return [GCDTimer timerOnMainQueueWithLeeway:TIMER_LEEWAY_MEDIUM name:name];
}


+ (id)timerOnMainQueue
{
    return [GCDTimer timerOnMainQueueWithName:nil];
}


- (void)invalidate
{
    @synchronized (self) {
        if (_isValid) {
            _isValid = NO;
            dispatch_source_cancel(_timer);
        }
    }
}


- (void)scheduleBlock:(void (^)(void))block afterInterval:(NSTimeInterval)interval
{
    [self scheduleBlock:block afterInterval:interval repeat:NO];
}


- (void)scheduleBlock:(void (^)(void))block afterInterval:(NSTimeInterval)interval repeat:(BOOL)repeat
{
    @synchronized (self) {
        if (_isValid) {
            @throw [NSException exceptionWithName:GCDTimerException
                                           reason:@"Attempt to schedule block while timer is valid."
                                         userInfo:@{ GCDTimerNameKey : _name }];
        }
        
        dispatch_time_t startTime;
        dispatch_time_t intervalInNanoseconds = (dispatch_time_t)(NSEC_PER_SEC * interval);
        if (_leeway >= TIMER_LEEWAY_HIGH) {
            /*
             * Prevent time-drift for long-running and/or imprecise timers.
             */
            startTime = dispatch_walltime(NULL, intervalInNanoseconds);
        }
        else {
            startTime = dispatch_time(DISPATCH_TIME_NOW, intervalInNanoseconds);
        }
        
        dispatch_source_set_timer(_timer, startTime, intervalInNanoseconds, _leeway);
        
        void (^eventHandler)(void) = ^{
            if (!repeat) {
                [self invalidate];
            }
            block();
        };
        
        dispatch_source_set_event_handler(_timer, eventHandler);
        
        _isValid = YES;
        
        dispatch_resume(_timer);
    }
}

@end

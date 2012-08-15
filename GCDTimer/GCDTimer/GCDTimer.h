//
//  GCDTimer.h
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

#import <Foundation/Foundation.h>

#define GCDTimerException @"GCDTimerException"
#define GCDTimerNameKey @"GCDTimerNameKey"

static const uint64_t TIMER_LEEWAY_NONE        = 0;
static const uint64_t TIMER_LEEWAY_LOW         = 1000 * 1000;
static const uint64_t TIMER_LEEWAY_MEDIUM      = 100 * 1000 * 1000;
static const uint64_t TIMER_LEEWAY_HIGH        = 1000 * 1000 * 1000;
static const uint64_t TIMER_LEEWAY_VERY_HIGH   = 30 * 1000 * 1000 * 1000;

/**
 * @class GCDTimer
 * @brief An efficient, thread-safe GCD-based timer implementation. GCDTimer allows for customization
 * of the dispatch queue that is fired back on, as well as the required precision of the timer.
 */
@interface GCDTimer : NSObject
{
    dispatch_source_t _timer;
    uint64_t _leeway;
    BOOL _isValid;
    NSString *_name;
}

@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly) NSString *name;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue leeway:(uint64_t)leeway name:(NSString *)name;

+ (id)timerOnQueue:(dispatch_queue_t)queue withLeeway:(uint64_t)leeway name:(NSString *)name;
+ (id)timerOnQueue:(dispatch_queue_t)queue withName:(NSString *)name;
+ (id)timerOnQueue:(dispatch_queue_t)queue;

+ (id)timerOnMainQueueWithLeeway:(uint64_t)leeway name:(NSString *)name;
+ (id)timerOnMainQueueWithName:(NSString *)name;
+ (id)timerOnMainQueue;

+ (id)timerOnCurrentQueueWithLeeway:(uint64_t)leeway name:(NSString *)name;
+ (id)timerOnCurrentQueueWithName:(NSString *)name;
+ (id)timerOnCurrentQueue;

- (void)invalidate;
- (void)scheduleBlock:(void (^)(void))block afterInterval:(NSTimeInterval)interval;
- (void)scheduleBlock:(void (^)(void))block afterInterval:(NSTimeInterval)interval repeat:(BOOL)repeat;

@end

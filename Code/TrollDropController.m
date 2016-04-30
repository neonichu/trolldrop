//
//  TrollDropController.m
//  trolldrop
//
//  Created by Boris Bügling on 30/04/16.
//  Copyright © 2016 Boris Bügling. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

#import "Sharing.h"
#import "Trollface.h"
#import "TrollDropController.h"

static NSString* tmpFilePath = @"/tmp/trollface.jpg";

static void term(int signum) {
    unlink([tmpFilePath UTF8String]);
    exit(0);
}

static void setupSignalHandlers() {
    struct sigaction action;
    memset(&action, 0, sizeof(struct sigaction));
    action.sa_handler = term;

    if (sigaction(SIGINT, &action, NULL) < 0) {
        perror ("sigaction");
    }

    if (sigaction(SIGTERM, &action, NULL) < 0) {
        perror ("sigaction");
    }
}

#pragma mark -

@interface NSObject ()

-(void *)node;

-(id)machineName;
-(id)personName;

@end

#pragma mark -

@interface TrollDropController () {
    dispatch_source_t timer;
}

@property FIAirDropViewGutsController* guts;
@property NSTimeInterval interval;

@property (readonly) NSArray* listItems;
@property (readonly) id listViewController;

@end

#pragma mark -

@implementation TrollDropController

-(NSURL*)extractTrollface {
    NSData* data = [NSData dataWithBytesNoCopy:__trollface length:__trollface_len freeWhenDone:NO];
    [data writeToFile:tmpFilePath atomically:YES];
    return [NSURL fileURLWithPath:tmpFilePath];
}

-(NSArray*)listItems {
    NSArrayController* controller = (NSArrayController*)[self.listViewController dataSource];
    return controller.arrangedObjects;
}

-(id)listViewController {
    return [self.guts valueForKey:@"listViewController"];
}

#pragma mark -

-(id)initWithTrollfaceInterval:(NSTimeInterval)interval {
    self = [super init];

    if (self) {
        self.interval = interval;
    }

    return self;
}

#pragma mark -

-(void)run {
    setupSignalHandlers();

    NSURL* trollfaceUrl = [self extractTrollface];

    self.guts = [objc_getClass("FIAirDropViewGutsController") new];
    self.guts.urlsToSend = @[ trollfaceUrl ];

    [self.guts resumeAirDropDiscovery];
    [self.guts viewDidMoveToWindow];

    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    NSTimeInterval first = MIN(self.interval, 5.0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(first * NSEC_PER_SEC)), mainQueue, ^{
        if (self.listItems.count == 0) {
            printf("No AirDrop targets found.\n");
            term(0);
        }

        for (id item in self.listItems) {
            printf("💻  %s - 👨🏽  %s\n",
                   [[item machineName] UTF8String],
                   [[item personName] UTF8String]);
        }
    });

    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mainQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, self.interval * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        for (id item in self.listItems) {
            printf("👹  🔜  %s\n", [[item machineName] UTF8String]);

            void* node = [item node];
            [self.guts personClicked:node];
        }
    });
    dispatch_resume(timer);
}

@end

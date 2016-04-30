//
//  main.m
//  trolldrop
//
//  Created by Boris Bügling on 30/04/16.
//  Copyright © 2016 Boris Bügling. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "TrollDropController.h"

int main(int argc, const char * argv[]) {
    NSTimeInterval interval = 0.0;

    if (argc > 1) {
        interval = [[NSString stringWithUTF8String:argv[1]] doubleValue];
    }

    if (interval < 1) {
        interval = 15.0;
    }

    @autoreleasepool {
        NSApplicationLoad();

        TrollDropController* controller = [[TrollDropController alloc] initWithTrollfaceInterval:interval];
        [controller run];

        [NSApp run];
    }
    return 0;
}

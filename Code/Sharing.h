//
//  Sharing.h
//  trolldrop
//
//  Created by Boris Bügling on 30/04/16.
//  Copyright © 2016 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FIAirDropViewGutsController : NSObject

@property(copy, nonatomic) NSArray *urlsToSend;

- (void)configureForAirDropAvailability;
- (void)personClicked:(void *)perform;
- (void)resumeAirDropDiscovery;

- (void)viewDidMoveToWindow;

@end

//
//  NSScanner+SpikeAdditions.h
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScanner (NSScanner_SpikeAdditions)

- (void)eatWS;
- (void)eat:(NSString *)string;
- (BOOL)detect:(NSString *)string;

@end

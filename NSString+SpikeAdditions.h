//
//  NSString+SpikeAdditions.h
//  Spike
//
//  Created by Matt Mower on 22/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (NSString_SpikeAdditions)

- (NSString *)stringByRemovingANSIEscapeSequences;

@end

//
//  NSData+ZlibAdditions.h
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSData (NSData_ZlibAdditions)

- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end

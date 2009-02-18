//
//  NSScanner+SpikeAdditions.m
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "NSScanner+SpikeAdditions.h"

@implementation NSScanner (NSScanner_SpikeAdditions)

- (void)eatWS {
  [self scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
}

- (void)eat:(NSString *)string {
  [self scanString:string intoString:nil];
}

- (BOOL)detect:(NSString *)string {
  return [self scanString:string intoString:nil];
}

@end

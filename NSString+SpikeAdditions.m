//
//  NSString+SpikeAdditions.m
//  Spike
//
//  Created by Matt Mower on 22/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "NSString+SpikeAdditions.h"

@implementation NSString (NSString_SpikeAdditions)

- (NSString *)stringByRemovingANSIEscapeSequences {
  NSMutableString *filteredString = [NSMutableString stringWithCapacity:[self length]];
  NSScanner *scanner              = [NSScanner scannerWithString:self];
  NSString *buffer;

  while( ![scanner isAtEnd] ) {
    if( [scanner scanUpToCharactersFromSet:[NSCharacterSet controlCharacterSet] intoString:&buffer] ) {
      [filteredString appendString:buffer];
    }

    if( ![scanner isAtEnd] && [scanner scanCharactersFromSet:[NSCharacterSet controlCharacterSet] intoString:nil] ) {
      [scanner scanUpToCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:nil];
      [scanner setScanLocation:[scanner scanLocation]+1];
    }
  }

  return filteredString;
}

@end

//
//  HaltedColumnTransformer.m
//  Spike
//
//  Created by Matt Mower on 15/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "HaltedColumnTransformer.h"

@implementation HaltedColumnTransformer

// + (void)initialize {
//   if( !onImage ) {
//     onImage = [NSImage imageNamed:@"red_dot.tif"];
//   }
// }

+ (Class)transformedValueClass {
  return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
  return NO;
}

- (id)transformedValue:(id)value {
  if( [value boolValue] ) {
    return [NSImage imageNamed:@"NSActionTemplate"];
  } else {
    return nil;
  }
}

@end

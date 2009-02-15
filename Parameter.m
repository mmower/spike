//
//  Parameter.m
//  Spike
//
//  Created by Matt Mower on 14/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "Parameter.h"

@implementation Parameter

- (id)initWithName:(NSString *)aName {
  if( ( self = [self init] ) ) {
    [self setName:aName];
    [self setLeaf:YES];
  }
  
  return self;
}

@synthesize name;
@synthesize value;

@dynamic groupedParams;

- (NSArray *)groupedParams {
  return groupedParams;
}

- (void)setGroupedParams:(NSArray *)newParamGroup {
  groupedParams = newParamGroup;
  [self setLeaf:( groupedParams == nil )];
}

@synthesize leaf;

@end

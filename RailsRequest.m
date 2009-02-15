//
//  RailsRequest.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "RailsRequest.h"

@implementation RailsRequest

- (id)init {
  if( ( self = [super init] ) ) {
    renders = [[NSMutableArray alloc] init];
  }
  
  return self;
}

@synthesize status;
@synthesize method;
@synthesize when;
@synthesize client;
@synthesize url;
@synthesize controller;
@synthesize action;
@synthesize session;
@synthesize rps;
@synthesize realTime;
@synthesize renderTime;
@synthesize dbTime;
@synthesize params;
@synthesize renders;
@synthesize sourceLog;

@end

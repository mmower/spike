//
//  RailsRequest.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "RailsRequest.h"

#import "Parameter.h"

@implementation RailsRequest

- (id)init {
  if( ( self = [super init] ) ) {
    renders = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)postProcess {
  [self setFormat:@""];
  for( Parameter *param in params ) {
    if( [[param name] isEqualToString:@"format"] ) {
      [self setFormat:[param value]];
    }
  }
}

@synthesize status;
@synthesize method;
@synthesize when;
@synthesize client;
@synthesize url;
@synthesize controller;
@synthesize action;
@synthesize format;
@synthesize session;
@synthesize rps;
@synthesize realTime;
@synthesize renderTime;
@synthesize dbTime;
@synthesize params;
@synthesize renders;
@synthesize sourceLog;
@synthesize halted;
@synthesize filter;

@end

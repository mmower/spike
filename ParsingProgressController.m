//
//  ParsingProgressController.m
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "ParsingProgressController.h"

@implementation ParsingProgressController

@synthesize statusField;
@synthesize panel;
@synthesize indicator;

- (id)init {
  return [self initWithWindowNibName:@"ParsingProgress"];
}

- (void)windowDidLoad {
  [indicator setIndeterminate:YES];
}

- (void)setMin:(double)min max:(double)max {
  [indicator setMinValue:min];
  [indicator setMaxValue:max];
  [indicator setDoubleValue:min];
  [indicator setIndeterminate:NO];
}

- (void)update:(double)value {
  [indicator setDoubleValue:value];
}

- (void)setStatus:(NSString *)status {
  [statusField setStringValue:status];
}

- (void)setAnimated:(BOOL)animated {
  if( animated ) {
    [indicator setUsesThreadedAnimation:YES];
    [indicator startAnimation:self];
  } else {
    [indicator stopAnimation:self];
  }
}

@end

//
//  AppController.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "AppController.h"

@implementation AppController

@synthesize focusMenuItem;

#pragma mark Delegate hooks

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
  return NO;
}

@end

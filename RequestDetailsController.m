//
//  RequestDetailsController.m
//  Spike
//
//  Created by Matt Mower on 15/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "RequestDetailsController.h"

#import "AppController.h"

@implementation RequestDetailsController

- (id)initWithAppController:(AppController *)theAppController {
  if( ( self = [super initWithWindowNibName:@"RequestDetails"] ) ) {
    appController = theAppController;
  }
  return self;
}

@synthesize appController;

@end

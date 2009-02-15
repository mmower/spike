//
//  RequestDetailsController.h
//  Spike
//
//  Created by Matt Mower on 15/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface RequestDetailsController : NSWindowController {
  AppController *appController;
}

@property (readonly)  AppController *appController;

- (id)initWithAppController:(AppController *)theAppController;

@end

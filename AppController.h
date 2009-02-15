//
//  AppController.h
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RequestDetailsController;

@interface AppController : NSObject {
            RequestDetailsController  *requestDetailsController;
            NSArray                   *requests;
  
  IBOutlet  NSArrayController         *requestsController;
  IBOutlet  NSPanel                   *progressPanel;
  IBOutlet  NSProgressIndicator       *progressIndicator;
}

@property (assign)    NSArray             *requests;
@property (assign)    NSArrayController   *requestsController;

@property (readonly)  NSPanel             *progressPanel;
@property (readonly)  NSProgressIndicator *progressIndicator;

- (IBAction)openDocument:(id)sender;

@end

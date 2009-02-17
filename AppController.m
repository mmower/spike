//
//  AppController.m
//  Spike
//
//  Created by Matt Mower on 13/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "AppController.h"

#import "LogParser.h"
#import "RailsRequest.h"
#import "RequestDetailsController.h"

@implementation AppController

@synthesize requests;
@synthesize requestsController;
@synthesize progressPanel;
@synthesize progressIndicator;

- (void)awakeFromNib {
  requestDetailsController = [[RequestDetailsController alloc] initWithAppController:self];
  [requestDetailsController showWindow:self];
}


- (IBAction)openDocument:(id)sender {
  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  [openDlg setCanChooseFiles:YES];
  [openDlg setCanChooseDirectories:NO];
  if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton ) {
    [NSThread detachNewThreadSelector:@selector(parseLogFile:) toTarget:self withObject:[[openDlg filenames] objectAtIndex:0]];
  }
}


- (IBAction)removeSimilarRequests:(id)sender {
  // Get controller & action of selected request
  RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
  if( request ) {
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"!( controller == %@ AND action == %@ )",[request controller],[request action]];
    NSLog( @"Deleting using predicate: %@", filterPredicate );
    [self setRequests:[requests filteredArrayUsingPredicate:filterPredicate]];
  }
}


- (void)parseLogFile:(NSString *)logFile {
  LogParser *parser = [[LogParser alloc] initWithAppController:self];
  [self setRequests:[parser parseLogFile:logFile]];
}


@end

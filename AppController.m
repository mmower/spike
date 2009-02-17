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

static NSString *SearchToolbarItemIdentifier = @"spike.searchField";


@interface AppController (PrivateAppController)
@end


@implementation AppController

@synthesize requests;
@synthesize requestsController;
@synthesize progressPanel;
@synthesize progressIndicator;

- (void)awakeFromNib {
  requestDetailsController = [[RequestDetailsController alloc] initWithAppController:self];
  [requestDetailsController showWindow:self];
}


#pragma mark NSToolbar delegate implementations


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
  NSLog( @"toolbarAllowedItemIdentifiers:%@", aToolbar );
  return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
  NSLog( @"toolbarDefaultItemIdentifiers:%@", aToolbar );
  return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSLog( @"toolbar:%@ itemForItemIdentifier:%@ willBeInsertedIntoToolbar:%@", aToolbar, itemIdentifier, flag ? @"YES" : @"NO" );
  NSToolbarItem *toolbarItem = nil;
  
  if( [itemIdentifier isEqualTo:SearchToolbarItemIdentifier] ) {
    toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbarItem setView:searchField];
    [toolbarItem setMinSize:[searchField frame].size];
    [toolbarItem setMaxSize:[searchField frame].size];
  }
  
  return toolbarItem;
}


#pragma mark Actions


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

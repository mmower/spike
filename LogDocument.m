//
//  LogDocument.m
//  Spike
//
//  Created by Matt Mower on 18/02/2009.
//  Copyright 2009 LucidMac Software. All rights reserved.
//

#import "LogDocument.h"

#import "AppController.h"
#import "LogParser.h"
#import "RailsRequest.h"
#import "RequestDetailsController.h"

static NSString *SearchToolbarItemIdentifier = @"spike.searchField";

@interface LogDocument (PrivateMethods)
- (void)parseLogFile:(NSData *)data;
@end

@implementation LogDocument

- (void)makeWindowControllers {
  [self addWindowController:[[NSWindowController alloc] initWithWindowNibName:@"LogDocument" owner:self]];
  [self addWindowController:[[RequestDetailsController alloc] initWithDocument:self]];
  
  // requestDetailsController = ;
  // [requestDetailsController showWindow:self];
}


@synthesize requests;


#pragma mark NSToolbar delegate implementations

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
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

- (IBAction)removeSimilarRequests:(id)sender {
  // Get controller & action of selected request
  RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
  if( request ) {
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"!( controller == %@ AND action == %@ )",[request controller],[request action]];
    NSLog( @"Deleting using predicate: %@", filterPredicate );
    [self setRequests:[requests filteredArrayUsingPredicate:filterPredicate]];
  }
}


#pragma mark Implementation

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
  [NSThread detachNewThreadSelector:@selector(parseLogFile:) toTarget:self withObject:data];
  return YES;
}


- (void)parseLogFile:(NSData *)data {
  LogParser *parser = [[LogParser alloc] initWithDocument:self];
  [self setRequests:[parser parseLogData:data]];
}


@end

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

static NSString *SearchToolbarItemIdentifier = @"spike.searchField";

@interface LogDocument (PrivateMethods)
- (void)parseLogFile:(NSData *)data;
- (NSData *)gunzipedDataFromData:(NSData *)compressedData;
@end

@implementation LogDocument

- (void)makeWindowControllers {
  NSWindowController *documentController = [[NSWindowController alloc] initWithWindowNibName:@"LogDocument" owner:self];
  [self addWindowController:documentController];
  NSWindowController *detailsController = [[NSWindowController alloc] initWithWindowNibName:@"RequestDetails" owner:self];
  [self addWindowController:detailsController];
  // [detailsController showWindow:self];
}


@synthesize requests;
@synthesize requestsController;


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
  SEL sel;
  
  if( [typeName isEqualToString:@"Compressed Log File"] ) {
    sel = @selector(parseCompressedLogData:);
  } else {
    sel = @selector(parseUncompressedLogData:);
  }
  
  [NSThread detachNewThreadSelector:sel toTarget:self withObject:data];
  
  return YES;
}


- (void)parseCompressedLogData:(NSData *)data {
  LogParser *parser = [[LogParser alloc] initWithDocument:self];
  [self setRequests:[parser parseLogData:data isCompressed:YES]];
  
}

- (void)parseUncompressedLogData:(NSData *)data {
  LogParser *parser = [[LogParser alloc] initWithDocument:self];
  [self setRequests:[parser parseLogData:data isCompressed:NO]];
}


@end

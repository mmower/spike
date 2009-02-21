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

static NSString *ReloadToolbarItemIdentifier = @"spike.toolbar.reload";
static NSString *FocusToolbarItemIdentifier = @"spike.toolbar.focus";
static NSString *RemoveToolbarItemIdentifier = @"spike.toolbar.remove";
static NSString *SearchToolbarItemIdentifier = @"spike.toolbar.search";

float adjusted_brightness( float brightness ) {
  brightness *= 1.5;
  if( brightness > 1.0 ) {
    brightness = 1.0;
  }
  return brightness;
}

static NSMutableDictionary *HTTPMethodColors;

@interface LogDocument (PrivateMethods)
+ (NSColor *)colorForHTTPMethod:(NSString *)method;
- (void)parseLogFile:(NSData *)data;
- (NSData *)gunzipedDataFromData:(NSData *)compressedData;
@end

@implementation LogDocument

+ (NSColor *)colorForHTTPMethod:(NSString *)method {
  NSColor *color = [HTTPMethodColors objectForKey:[method uppercaseString]];
  if( color ) {
    return color;
  } else {
    return [NSColor controlTextColor];
  }
}


+ (void)initialize {
  if( !HTTPMethodColors ) {
    HTTPMethodColors = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [HTTPMethodColors setObject:[NSColor colorWithDeviceRed:(20.0/255) green:(128.0/255) blue:(65.0/255) alpha:1.0] forKey:@"GET"];
    [HTTPMethodColors setObject:[NSColor blueColor] forKey:@"PUT"];
    [HTTPMethodColors setObject:[NSColor blueColor] forKey:@"POST"];
    [HTTPMethodColors setObject:[NSColor redColor] forKey:@"DELETE"];
  }
}


@synthesize requests;
@synthesize requestsController;


#pragma mark NSDocument implementation

- (void)makeWindowControllers {
  NSWindowController *documentController = [[NSWindowController alloc] initWithWindowNibName:@"LogDocument" owner:self];
  [self addWindowController:documentController];
  NSWindowController *detailsController = [[NSWindowController alloc] initWithWindowNibName:@"RequestDetails" owner:self];
  [self addWindowController:detailsController];
}

- (NSString *)displayName {
  return [[self fileURL] path];
}


#pragma mark NSWindow delegate implementation

- (void)windowWillClose:(NSNotification *)notification {
  [self close];
}


#pragma mark NSToolbar delegate implementations

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray arrayWithObjects:ReloadToolbarItemIdentifier,FocusToolbarItemIdentifier,RemoveToolbarItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray arrayWithObjects:ReloadToolbarItemIdentifier,FocusToolbarItemIdentifier,RemoveToolbarItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier,SearchToolbarItemIdentifier,nil];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *toolbarItem = nil;
  
  if( [itemIdentifier isEqualTo:ReloadToolbarItemIdentifier] ) {
    toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbarItem setLabel:@"Reload"];
    [toolbarItem setImage:[NSImage imageNamed:@"refresh_32.gif"]];
    [toolbarItem setAction:@selector(revertDocumentToSaved:)];
  } else if( [itemIdentifier isEqualTo:FocusToolbarItemIdentifier] ) {
    toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbarItem setLabel:@"Focus"];
    [toolbarItem setImage:[NSImage imageNamed:@"search_32.gif"]];
    [toolbarItem setAction:@selector(focusOnRequest:)];
    focusToolbarItem = toolbarItem;
  } else if( [itemIdentifier isEqualTo:RemoveToolbarItemIdentifier] ) {
    toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbarItem setLabel:@"Remove"];
    [toolbarItem setImage:[NSImage imageNamed:@"close_32.gif"]];
    [toolbarItem setAction:@selector(removeSimilarRequests:)];
  } else if( [itemIdentifier isEqualTo:SearchToolbarItemIdentifier] ) {
    toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [toolbarItem setView:searchField];
    [toolbarItem setMinSize:[searchField frame].size];
    [toolbarItem setMaxSize:[searchField frame].size];
  }
  
  return toolbarItem;
}


#pragma mark NSTableView delegate implementations

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex {
  if( [[tableColumn identifier] isEqualToString:@"method"] ) {
    NSColor *color = [[self class] colorForHTTPMethod:[cell stringValue]];
    if( rowIndex == [tableView selectedRow] ) {
      color = [NSColor colorWithDeviceHue:[color hueComponent] saturation:[color saturationComponent] brightness:adjusted_brightness([color brightnessComponent]) alpha:1.0];
    }
    [cell setTextColor:color];
  } else if( [cell respondsToSelector:@selector(setTextColor:)]) {
    [cell setTextColor:[NSColor controlTextColor]];
  }
}


#pragma mark Actions

- (IBAction)removeSimilarRequests:(id)sender {
  // Get controller & action of selected request
  RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
  if( request ) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!( controller == %@ AND action == %@ )",[request controller],[request action]];
    [self setRequests:[requests filteredArrayUsingPredicate:predicate]];
  }
}


- (IBAction)focusOnRequest:(id)sender {
  
  NSMenuItem *focusMenuItem = [[NSApp delegate] focusMenuItem];
  
  if( [focusMenuItem state] == NSOffState ) {
    RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
    if( request ) {
      [searchField setStringValue:@""];
      [requestsController setFilterPredicate:[NSPredicate predicateWithFormat:@"controller == %@ AND action == %@",[request controller],[request action]]];
    }
    
    [focusToolbarItem setLabel:@"Unfocus"];
    [focusMenuItem setState:NSOnState];
  } else {
    [requestsController setFilterPredicate:nil];
    
    [focusToolbarItem setLabel:@"Focus"];
    [focusMenuItem setState:NSOffState];
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
  [self performSelectorOnMainThread:@selector(setRequests:) withObject:[parser parseLogData:data isCompressed:YES] waitUntilDone:YES];
}


- (void)parseUncompressedLogData:(NSData *)data {
  LogParser *parser = [[LogParser alloc] initWithDocument:self];
  [self performSelectorOnMainThread:@selector(setRequests:) withObject:[parser parseLogData:data isCompressed:NO] waitUntilDone:YES];
}


@end

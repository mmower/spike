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
+ (NSColor *)colorForHTTPMethod:(NSString *)method brighten:(BOOL)brighten;
@end

@implementation LogDocument

/*
 * Returns an NSColor associated with the specified HTTP method and, optionally,
 * brightens the colour first.
 */
+ (NSColor *)colorForHTTPMethod:(NSString *)method brighten:(BOOL)brighten {
  NSColor *color = [HTTPMethodColors objectForKey:[method uppercaseString]];
  if( color ) {
    if( brighten ) {
      color = [NSColor colorWithDeviceHue:[color hueComponent] saturation:[color saturationComponent] brightness:adjusted_brightness([color brightnessComponent]) alpha:1.0];
    }
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


@synthesize compressedLog;
@synthesize requests;
@synthesize requestsController;


#pragma mark NSDocument implementation

- (void)makeWindowControllers {
  [self addWindowController:[[NSWindowController alloc] initWithWindowNibName:@"LogDocument" owner:self]];
  [self addWindowController:[[NSWindowController alloc] initWithWindowNibName:@"RequestDetails" owner:self]];
}


- (NSString *)displayName {
  return [[self fileURL] path];
}


#pragma mark NSWindow delegate implementation

/*
 * Trigger a read of the logfile from a background thread. The thread will update
 * the user interface when the data has been parsed. Detects whether the document
 * corresponds to a gzip'd log and triggers decompression where necessary.
 */
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
  if( [typeName isEqualToString:@"Compressed Log File"] ) {
    [self setCompressedLog:YES];
  } else {
    [self setCompressedLog:NO];
  }
  
  logParser = [[LogParser alloc] initWithDocument:self];
  
  // The parser handles the log data on a background thread. When it is done
  // it will call back on the main thread to set the requests property.
  [NSThread detachNewThreadSelector:@selector(parseLogData:)
                           toTarget:logParser
                         withObject:data];
  
  // Always return YES. Not quite sure what we should do if there is ever an error
  // in the legitimate load process.
  return YES;
}


/*
 * Close document when main window closes.
 */
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
    [toolbarItem setAction:@selector(reloadChangedLog:)];
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


/*
 * For the HTTP Method column, color the text appropriately. All other text columns
 * get the default color. The selected row gets a brighter color to compensate for
 * the dark background of that row.
 */
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex {
  if( [[tableColumn identifier] isEqualToString:@"method"] ) {
    [cell setTextColor:[[self class] colorForHTTPMethod:[cell stringValue]
                                               brighten:(rowIndex == [tableView selectedRow])]];
  } else if( [cell respondsToSelector:@selector(setTextColor:)]) {
    [cell setTextColor:[NSColor controlTextColor]];
  }
}


#pragma mark Actions

/*
 * Destructively remove all requests from the table that match the currently
 * selected controller & action.
 */
- (IBAction)removeSimilarRequests:(id)sender {
  RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
  if( request ) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!( controller == %@ AND action == %@ )",[request controller],[request action]];
    [self setRequests:[requests filteredArrayUsingPredicate:predicate]];
  }
}


/*
 * Remove any user supplied filter predicate and replace with a predicate to
 * select only those rows matching the currently selected rows controller and
 * action.
 */
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


/*
 * Take the session from the currently selected request and filter on it.
 */
- (IBAction)followSession:(id)sender {
  RailsRequest *request = [[requestsController selectedObjects] objectAtIndex:0];
  if( request ) {
    [searchField setStringValue:@""];
    [requestsController setFilterPredicate:[NSPredicate predicateWithFormat:@"session == %@",[request session]]];
  }
}


/*
 * Reloads the log data but only reparses what is new since the last parse.
 */
- (IBAction)reloadChangedLog:(id)sender {
  NSLog( @"reloadChangedLog:" );
  // The parser handles the log data on a background thread. When it is done
  // it will call back on the main thread to set the requests property.
  [NSThread detachNewThreadSelector:@selector(parseLogData:)
                           toTarget:logParser
                         withObject:[NSData dataWithContentsOfURL:[self fileURL]]];
}


@end
